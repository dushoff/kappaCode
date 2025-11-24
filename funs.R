library(shellpipes)
odds2prob <- function(o){o/(1+o)}
prob2odds <- function(p){p/(1-p)}

makeDistData <- function(v){
	n <- length(v)
	realiz <- rpois(n, lambda = v)
	cFIdeal <- cumFrac(v)
	cFRealiz <- cumFrac(realiz)
	q  <- (1:n)/n
	qp <- (1:n)/sum(realiz>0)
	return(data.frame(q, qp, cFIdeal, cFRealiz))
}

## HERE
densHist <- function(.data
    , xlab = "cases per case"
    , ylab = "density"
    , colorVar = "distParms"
    , colorVals = NULL
    , colorLab = NULL
    , groupVar = NULL
    , clearFill = FALSE
){
    if(is.null(colorLab)){colorLab <- colorVar}
    p <- ggplot(.data, aes(x = x
        , y = d
        , color = get(eval(colorVar))
        , fill = get(eval(colorVar))
    )
    ) +
    geom_point(alpha = 0, aes(group = get(eval(groupVar)))
        # , key_glyph = "point"
    ) +
    geom_line(aes(alpha = as.numeric(distType == "act"), group = get(eval(groupVar)))
        # , key_glyph = "path"
    ) +

    # set up a guide for the plotting type, using the alpha scale that renders
    # outside type invisible
    scale_alpha_identity(breaks = c(0,1)
        # , range = c(0,1)
        , labels = c("expected infectiousness", "secondary case")
        , guide = guide_legend(title = "distribution type"
            , order = 2
            , override.aes = list(
                linewidth = 0.5
                , linetype = c("solid", "32")
                , shape = 22
                , size = c(0, 6)
                , fill = c(NA
                    , "grey60"
                )
                , alpha = 0.7
                # , color = NA
                #
            )
        )
    ) +
    scale_fill_brewer(palette = "Dark2", name = colorLab, labels = colorVals
        , guide = guide_legend(order = 1)
    ) +
    scale_color_brewer(palette = "Dark2", name = colorLab, labels = colorVals
        , guide = guide_legend(order = 1)
    ) +
    scale_size_area() +
    theme_classic() +
    labs(x = xlab
        , y = ylab
        , color = colorLab
        , fill = colorLab
    ) + theme(legend.position = c(xpos, ypos)
              , legend.justification = c("right", "bottom")
              , legend.title = element_text(size = legendTitleFontSize)
              , legend.text  = element_text(size = legendFontSize))
    if(!clearFill){
        p <- p + geom_bar(aes(alpha = 0.5 * as.numeric(distType != "act")
                              , width = barWidth, group = get(eval(groupVar)))
            , stat = "identity"
            , position = "identity"
            , color = scales::alpha("white", alpha = 0)
            # , key_glyph = "point"
        )
    }
    return(p)
}


# now we want to build the inequality plots
ineq <- function(dat, colorVar = bquote(R[0])
                 , colorVals = betaList){
    dat |>
    ggplot(aes(frac, val, color = distParms, linetype = distType)) +
    geom_hline(yintercept = 0.8, linewidth = 0.5, color = "grey") +
    geom_vline(xintercept = 0.2, linewidth = 0.5, color = "grey") +
    geom_line(linewidth = 0.6
        #, alpha = 0.8
    ) +
    theme_classic() +
    scale_color_brewer(palette = "Dark2", name = colorVar
                       , labels = colorVals
                       , guide = "none") +
    labs(x = "fraction of infectors (ranked)"
        , y = "\ncumulative fraction of new infections"
        , linetype = "distribution type"
    ) + theme(legend.position = c(xpos, ypos)
              , legend.justification = c("right", "bottom")
              , legend.title = element_text(size = legendTitleFontSize)
              , legend.text  = element_text(size = legendFontSize))
}

mderivs <- function(time, vars, parms){
  with(as.list(c(vars,parms)),{
  Bt<- plist$B0
  Sp<-flist$sfun(time) #fraction of susceptible
  Ri <- Bt*Sp
  dens <- with(plist,
      cars^cars*(time - T0)^(cars-1)*exp(-cars*(time - T0))/factorial(cars-1))
  return(list(c(
    Ri
    , dens
    , Rc*dens
    , Rc*Rc*dens
  )))
  })
}

cMoments <- function(time, sfun, T0, cars, B0){
  mom <- as.data.frame(ode(
    y=c(Rc=0, cumden=0, Rctot=0, RcSS=0)
    , func=mderivs
    , times=time
    , parms=list(
      plist=list(T0=T0, cars=cars, B0=B0)
      , flist=list(sfun=sfun)
    )
  ))
  return(mom)
}
cCalc <- function(time, cohort, sfun, tol=1e-4, cars, B0){
  sTime <- time[time>=cohort]
  mom <- cMoments(sTime, sfun, T0=cohort, cars=cars, B0=B0)
  with(mom[nrow(mom), ], {
    stopifnot(abs(cumden-1)<tol)
    Rctot=Rctot/cumden
    RcSS=RcSS/cumden
    return(list(
      cohort=cohort, Rc=Rctot, varRc=(RcSS-Rctot^2), RcSS =RcSS
    ))
  })
}
RcStats <- function(B0=1
                    , cohortProp=0.6
                    , steps=300
                    , dfun = boxcar
                    , cars = 1
                    , finTime = 365
                    , y0 = 1e-9
                    , t0 = 0){
  mySim<- sim(B0=B0, timeStep=finTime/steps
              ,finTime=finTime, dfun=dfun, cars=cars, y0 =y0, t0=t0)
  with(mySim, {
    maxCohort <- t0 + cohortProp*finTime
    ifun <- approxfun(time, B0*y*x, rule=2)
    cStats <- cohortStats( B0=B0, sdat=mySim, maxCohort=maxCohort, cars=cars)
    rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
    varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
    wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
    mom <- as.data.frame(ode(
      y=c(finS=0, mu=0, SS=0, V=0, w = 0, checkV = 0)
      , func=v1ODE
      , times=unlist(cStats$cohort)
      , parms=list(ifun=ifun, rcfun=rcfun, varrcfun=varrcfun,
                    wssfun = wssfun))
    )
    
    with(mom[nrow(mom), ], {
      mu <- mu/finS
      SS <- SS/finS
      w <- w/finS
      checkV <- (checkV/finS)
      within <- (V/finS)
      between <- (SS-mu^2)
      total = within + between
      otherCheck = (w-mu^2)
      Finalsize <- finS
      return(c(  stepSize=steps
                 , B0 = B0
                 , finTime=finTime
                 , Finalsize=Finalsize
                 , muRc=mu
                 , within=within
                 , checkWithin = checkV
                 , between=between
                 , withinSS = w
                 , totalVRc = total
                 , totalVRc_simplified = otherCheck
                 , totalKRc=total/mu^2
      ))
    })
  })
}
boxcar <- function(time, vars, parms){
  with(as.list(c(vars, parms)), {
    yvec <- (unlist(mget(paste0("y", 1:cars))))
    y <- sum(yvec)
    ydots <- numeric(cars)
    xdot <- -B0*y*x 
    ydots[[1]] <- B0*y*x- cars*yvec[[1]]
    cumdot <- B0*y*x
    if (cars > 1) {
      ydots[2:cars] <- cars * (yvec[1:(cars - 1)] - yvec[2:cars])
    }
    rdot <- cars*yvec[[cars]] 
    out <- c(xdot, ydots, rdot, cumdot)
    return(list(out))
  }
  )
}
sim <- function(B0=1,  cars = 1, finTime=365,
                timeStep=0.1, dfun=boxcar,  t0 =0, 
                y0 = 1e-9){
  x0 <- 1-y0
  r0 <- 0
  cum0 <- y0
  infc <- c(y0,rep(0,cars-1))
  names(infc) <- paste0("y", 1:cars)
  y_init <- c(x = x0, infc, r=r0, cum = cum0)
  if(t0 !=0){timePoints<- c(0, seq(from=t0, to=t0 + finTime, by=timeStep))}else{
    timePoints<- seq(from=0, to=finTime, by=timeStep)}
  sim <- as.data.frame(ode(
    y = y_init
    , func=dfun
    , times=timePoints
    , parms=list(B0=B0, cars = cars)
  ))
  if(t0!=0){sim <- sim[!sim$time==0,]}
  return(within(sim, {
    if (cars>1){
      y <- rowSums(as.data.frame(mget(paste0("y", 1:cars))))
    }else{
      y <- y1
    }
    inc <- c(diff(cum), NA)
    
  }))
}
cohortStats <- function(B0 = 1
                        , sdat = NULL
                        , maxCohort = NULL
                        , cohortProp=0.6
                        , dfun = boxcar
                        , cars = 1
                        , ...){
  sfun <- approxfun(sdat$time, sdat$x, rule=2)
  cohorts <- with(sdat, time[time<=maxCohort])
  return(as.data.frame(t(
    sapply(cohorts, function(c) cCalc(sdat$time, cohort=c, sfun=sfun, tol=1e-4
                                      , cars=cars, B0 = B0
    ))
  )))
}

v1ODE <- function(time, vars, parms){
  with(as.list(c(vars,parms)),{
  inc <-ifun(time)
  Rc <- rcfun(time)
  varRc <- varrcfun(time)
  wss <- wssfun(time)
  return(list(c(  #finS=0, mu=0, SS=0, V=0, w = 0, checkV = 0
    inc #finS
    ,inc*Rc #mu
    ,inc*Rc*Rc #RSS
    ,inc*varRc #V
    ,inc*wss #w
    ,inc*(wss - Rc^2) #checkV
  )))
  })
}

peakAssigner<-function(R0){
  SIRsim<-sim(B0=R0, finTime=50, timeStep=0.001,  y0 = 1e-9)
  idx<-which.min(abs(SIRsim$x - 1/R0))
  return(SIRsim[idx,"time"])
}

v1Stats_tpeak <- function(B0=1
                          , cohortProp=0.6
                          , steps=300
                          , dfun = boxcar
                          , cars = 1
                          , tpeak = 1000
                          , finTime = 365
                          , cutoffTime = NULL
                          , y0 = 1e-9
                          , t0 = 0){
  mySim<- sim(B0=B0, timeStep=finTime/steps,
              finTime=finTime, dfun=dfun, cars=cars,  y0 =y0, t0=t0
  )
  with(mySim, {
    maxCohort <- t0 + cohortProp*finTime
    ifun <- approxfun(time, B0*y*x, rule=2)
    cStats <- cohortStats( B0 = B0,
                           sdat=mySim,
                           maxCohort=maxCohort, 
                           cars=cars)
    rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
    varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
    wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
    
    mom <- as.data.frame(ode(
      y=c(finS=0, mu=0, SS=0, V=0, w = 0, checkV = 0)
      , func=v1ODE
      , times=unlist(cStats$cohort)
      , parms=list(ifun=ifun, rcfun=rcfun, varrcfun=varrcfun,
                    wssfun = wssfun))
    )
    return(((map_dfr(cutoffTime, function(cuttime){
      idx <- which.min(abs(mom$time - tpeak*cuttime))
      with(mom[idx, ], {
        mu <- mu/finS
        SS <- SS/finS
        w <- w/finS
        checkV <- (checkV/finS)
        within <- (V/finS)
        between <- (SS-mu^2)
        total = within + between
        otherCheck = (w-mu^2)
        Finalsize <- finS
        return(data.frame(stepSize=steps
                          , B0 = B0
                          , finTime=finTime
                          , cutoffTime=cuttime
                          , Finalsize=Finalsize
                          , muRc=mu
                          , within=within
                          , checkWithin = checkV
                          , between=between
                          , withinSS = w
                          , totalVRc = total
                          , totalVRc_simplified = otherCheck
                          , totalKRc=total/mu^2
        ))
      })
    }
    )
    )
    ))
  })}

v1Stats_tpeak_obs <- function(B0=1
                              , steps=300
                              , dfun = boxcar
                              , cars = 1
                              , finTime = 365
                              , cutoffTime = NULL
                              , y0 = 1e-9
                              , t0 = 0){
  mySim<- sim(B0=B0, timeStep=finTime/steps,
              finTime=finTime, dfun=dfun, cars=cars,  y0 =y0, t0=t0
  )
  with(mySim, {
    maxCohort <- t0 + cutoffTime - 10*finTime/steps
    ifun <- approxfun(time, y*x, rule=2)
    cStats <- cohortStats_obs( B0 = B0,
                               sdat=mySim,
                               maxCohort=maxCohort, 
                               stopTime = cutoffTime,
                               cars=cars)
    rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
    varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
    wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
    cohortFracFun <- approxfun(cStats$cohort, cStats$cumden, rule = 2)
    mom <- as.data.frame(ode(
      y=c(finS=0, finSw=0,  mu=0, SS=0, V=0, w = 0, checkV = 0)
      , func=v1ODE_obs
      , times=unlist(cStats$cohort)
      , parms=list( B0 = B0, ifun=ifun, rcfun=rcfun, varrcfun=varrcfun,
                    wssfun = wssfun,
                    cohortFracFun = cohortFracFun)))
    with(mom[nrow(mom), ], {
      mu <- mu/finSw
      SS <- SS/finSw
      w <- w/finSw
      checkV <- (checkV/finSw)
      within <- (V/finSw)
      between <- (SS-mu^2)
      total = within + between
      otherCheck = (w-mu^2)
      Finalsize <- finS
      FinalsizeW <- finSw
      return(data.frame(stepSize=steps
                        , B0 = B0
                        , finTime=finTime
                        , cutoffTime=cutoffTime
                        , Finalsize=Finalsize
                        , FinalsizeW=FinalsizeW
                        , muRc=mu
                        , within=within
                        , checkWithin = checkV
                        , between=between
                        , withinSS = w
                        , totalVRc = total
                        , totalVRc_simplified = otherCheck
                        , totalKRc=total/mu^2
      ))
    })
  })}

saveEnvironment()
