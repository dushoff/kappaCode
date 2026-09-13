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

finalSize <- function(R0){
  susFrac <- uniroot(function(x){R0*(x-1)/log(x)-1}
                     , upper = 1-1e-12
                     , lower =1e-12
  )
  return(1-as.numeric(susFrac[1]))
  
}
recFun <- function(x, rPar = "exp"){
  if(rPar == "exp"){
    y <- rexp(x, rate = setGamma)
  }
  if(rPar == "const"){
    y <- rep(setGamma, max(x))
  }
  if(rPar == "gamma3"){
    y <- rgamma(max(x), rate = setGamma/3, shape = 3)
  }
  return(y)
}
## HERE
densHist <- function(.data
    , xlab = "Secondary cases"
    , ylab = "Density"
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
        , guide = guide_legend(title = "Distribution type"
            , order = 2
            , override.aes = list(
                linewidth = 0.5
                , linetype = c("solid", NA)
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
    scale_fill_viridis_d(option = "D", name = colorLab, labels = colorVals
        , guide = guide_legend(order = 1)
    ) +
    scale_color_viridis_d(option = "D", name = colorLab, labels = colorVals
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
        p <- p + geom_bar(
				aes(alpha = 0.5 * as.numeric(distType != "act")
					, width = barWidth
					, group = get(eval(groupVar))
				)
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
    # geom_hline(yintercept = 0.8, linewidth = 0.5, color = "grey") +
    # geom_vline(xintercept = 0.2, linewidth = 0.5, color = "grey") +
		geom_point(aes(x=0.2, y=0.8), color = "grey", shape = 4, size = 3) +
    geom_line(linewidth = 0.6
        #, alpha = 0.8
    ) +
    theme_classic() +
    scale_color_viridis_d(option = "D", name = colorVar
                       , labels = colorVals
                       , guide = "none") +
    labs(x = "Fraction of infectors (ranked)"
        , y = "\nCumulative fraction of new infections"
        , linetype = "Distribution type"
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
cohortStats <- function(B0
                        , sdat
                        , maxCohort = 200
                        , cars = 1
                        ){
  sfun <- approxfun(sdat$time, sdat$x, rule=2)
  cohorts <- with(sdat, time[time<=maxCohort])
  return(as.data.frame(t(
    sapply(cohorts, function(c) cCalc(sdat$time, cohort=c, sfun=sfun, tol=1e-4
                                      , cars=cars, B0 = B0
    ))
  )))
}

peakAssigner<-function(R0, y0= 1e-9){
  SIRsim<-sim(B0=R0, finTime=50, y0 = y0, timeStep = 1e-4)
  idx<-which.max(SIRsim$inc)
  #idx<-which.min(abs(SIRsim$x - 1/R0)) this one isn't accurate
  return(SIRsim[idx,"time"])
}
forcst <- function(B0
                , cohortProp=0.6
                , cars = 1
                , finTime2Ipeak = 8
                , nCohortPerIp=500
                , frcIpeak
                , y0 = 1e-9
                , t0 = 0){
  
  tpeak <- peakAssigner(B0, y0 = y0)
  timeStep <- tpeak/nCohortPerIp
  finTime <- finTime2Ipeak*tpeak
  mySim <- sim(B0=B0
            , timeStep=timeStep
            , finTime=finTime
            , y0 =y0
             )
  maxCohort <- t0 + max(frcIpeak)*tpeak
  ifun <- approxfun(mySim$time, B0*mySim$y*mySim$x, rule=2)
  cStats <- cohortStats( B0 = B0,
                         sdat=mySim,
                         maxCohort=maxCohort, 
                         cars=cars)
  rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
  varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
  wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
  finS0 <- y0
  mu0 <- cStats$Rc[[1]]
  w0 <- cStats$RcSS[[1]]
  V0 <- cStats$varRc[[1]]
  checkV0 <- cStats$RcSS[[1]] - mu0^2
  SS0 <- mu0^2  
  mom <- as.data.frame(ode(
      #y=c(finS=0, mu=0, SS=0, V=0, w = 0, checkV = 0)
        y=c(finS=finS0, mu=y0*mu0, SS=y0*SS0, V=y0*V0, w = y0*w0, checkV = y0*checkV0)
      , func=v1ODE
      , times=unlist(cStats$cohort)
      , parms=list(ifun=ifun, rcfun=rcfun, varrcfun=varrcfun,
                    wssfun = wssfun))
    )
    return(((map_dfr(frcIpeak, function(cuttime){
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
        return(data.frame(timeStep=timeStep
                          , B0 = B0
                          , finTime=finTime
                          , frcIpeak=cuttime
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
  }
cCalc_obs <- function(time, cohort, sfun, tol=1e-4, cars, stopTime = -4, B0){
  Bcohort<-B0
  Ri <- Bcohort*sfun(cohort)
  sTime <- time[time>=cohort & time<stopTime]
  mom <- cMoments(sTime, sfun, T0=cohort, cars=cars, 
                  B0=B0)
  with(mom[nrow(mom), ], {
    Rctot=Rctot/cumden
    RcSS=RcSS/cumden
    return(list(
      cohort=cohort, Ri = Ri, Rc=Rctot, varRc=(RcSS-Rctot^2)
      , RcSS =RcSS
      , cumden=cumden
    ))
  })
}
cCalc_trunc <- function(time, cohort, sfun,  cars=1, stopTime, B0){
	Bcohort<-B0
	Ri <- Bcohort*sfun(cohort)
	sTime <- time[time>=cohort & time<=stopTime]
	mom <- cMoments(sTime, sfun, T0=cohort, cars=cars, B0=B0)
	with(mom[nrow(mom), ], { #attribute the last Rc to those remained infectious after the stop time
			Rctot=Rctot + Rc*(1-cumden)
			RcSS=RcSS + Rc*Rc*(1-cumden)
			return(list(
				cohort=cohort
                                , Ri = Ri
                                , Rc=Rctot
                                , varRc=(RcSS-Rctot^2)
				, RcSS =RcSS
				, cumden=cumden
			))	
		
	})
}

cohortStats_trunc <- function(B0
		, sdat
		, maxInfCohort
		, cars = 1
		, stopTime
		){
	sfun <- approxfun(sdat$time, sdat$x, rule=2)
	cohorts <- with(sdat, time[time<=maxInfCohort])
df <- map_dfr(cohorts, function(c){cCalc_trunc(sdat$time
                                                ,cohort=c
                                                ,sfun=sfun
                                              #  ,tol=1e-4
                                                ,stopTime = stopTime
                                                ,B0 = B0
                                                  )}
                     )
return(df)
}

cohortStats_obs <- function(B0 = 1
                            , sdat = NULL
                            , maxCohort = NULL
                            , dfun = boxcar
                            , cars = 1
                            , stopTime = NULL
                            , ...){
  sfun <- approxfun(sdat$time, sdat$x, rule=2)
  cohorts <- with(sdat, time[time<=maxCohort])
  return(as.data.frame(t(
    sapply(cohorts, function(c) cCalc_obs(sdat$time, cohort=c, sfun=sfun, tol=1e-4,
                                          cars=cars,
                                           stopTime = stopTime,
                                          B0 = B0
    ))
  )))
}
cCalc_v1 <- function(time, cohort, sfun, tol=1e-4, cars, stopTime = -4, B0){
	Bcohort<-B0
	Ri <- Bcohort*sfun(cohort)
	sTime <- time[time>=cohort & time<stopTime]
	mom <- cMoments(sTime, sfun, T0=cohort, cars=cars, B0=B0)
	with(mom[nrow(mom), ], {
		Rctot=Rctot
		RcSS=RcSS
		return(list(
			cohort=cohort, Ri = Ri, Rc=Rctot, varRc=(RcSS-Rctot^2)
			, RcSS =RcSS
			, cumden=cumden
		))
	})
}

cohortStats_v1 <- function(B0 = 1
                          , sdat = NULL
			  , maxCohort = NULL
			  , dfun = boxcar
			  , cars = 1
			  , stopTime = NULL
			  , ...){
	sfun <- approxfun(sdat$time, sdat$x, rule=2)
	cohorts <- with(sdat, time[time<=maxCohort])
	return(as.data.frame(t(
		sapply(cohorts, function(c) cCalc_v1(sdat$time, cohort=c, sfun=sfun, tol=1e-4, cars=cars, stopTime = stopTime, B0 = B0	))
	)))
}
v1Stats_tpeak_obs <- function(B0=1
                              , steps=300
                              , dfun = boxcar
                              , cars = 1
                              , finTime = 365
                              , cutoffTime = NULL
                              , tpeak = 100
                              , y0 = 1e-9
                              , t0 = 0){
  mySim<- sim(B0=B0, timeStep=finTime/steps,
              finTime=finTime, dfun=dfun, cars=cars,  y0 =y0, t0=t0
  )
  with(mySim, {
    maxCohort <- t0 + cutoffTime - 2*finTime/steps
    stopifnot(maxCohort > 1*finTime/steps)
    ifun <- approxfun(time, B0*y*x, rule=2)
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
      , parms=list(ifun=ifun, rcfun=rcfun, varrcfun=varrcfun,
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
                        , cutoffTime=cutoffTime/tpeak
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


v1ODE_obs<-function (time, vars, parms) 
{
  inc <- parms$ifun(time)
  Rc <- parms$rcfun(time)
  varRc <- parms$varrcfun(time)
  wss <- parms$wssfun(time)
  cohortFrac <- parms$cohortFracFun(time)
  return(list(c(inc,
                inc * cohortFrac,
                inc * cohortFrac *  Rc,
                inc * cohortFrac * Rc * Rc,
                inc * cohortFrac * varRc, 
                inc * cohortFrac * wss,
                inc * cohortFrac * (wss - Rc^2)
  )))
}

truncSim <- function(B0
                 , nCohortPerIp=5000
                 , frcIpeak
                 , y0 = 1e-9
                ){

        tpeak <- peakAssigner(B0, y0 = y0)
        timeStep <- tpeak/nCohortPerIp
        finTime <- 2*frcIpeak*tpeak
        tol <- 2
        sdat <- sim(B0=B0
                    , timeStep=timeStep
                    , finTime=finTime
                    , y0 =y0
                       )
        maxInfCohort <- tpeak*(frcIpeak - tol/nCohortPerIp) #to avoid ode from raising error
        cStats <- cohortStats_trunc( B0 = B0
                               , sdat=sdat
                               , maxInfCohort=maxInfCohort
                               , stopTime = frcIpeak*tpeak
                              )
                #write.csv(cStats,file =paste0("B0_",B0,"frack_",frcIpeak,".csv"))
                ifun <- approxfun(sdat$time, B0*sdat$y*sdat$x, rule=2)
                rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
                varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
                wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
                finS0 <- y0
                mu0 <- cStats$Rc[[1]]
                w0 <- cStats$RcSS[[1]]
                V0 <- cStats$varRc[[1]]
                checkV0 <- cStats$RcSS[[1]] - mu0^2
                SS0 <- mu0^2
                moments <- as.data.frame(ode(
                   #To account for the index's contribution
                          y=c(finS=finS0, mu=y0*mu0, SS=y0*SS0, V=y0*V0, w = y0*w0, checkV = y0*checkV0)
                       #  y=c(finS = 0, mu = 0, SS = 0, V = 0, w = 0, checkV = 0)                      
                        , func=v1ODE
                        , rtol = 1e-10
                        , atol = 1e-12
                        , times= sdat[sdat$time <=maxInfCohort, "time"]   # cStats$cohort
                        , parms=list(ifun=ifun, rcfun=rcfun, varrcfun=varrcfun, wssfun = wssfun)
                                    )
                                      )
               # calculating moments while excluding the tol last cohorts, because their contributions haven't been computed
               # we include them to have them accounted in the final size
                mom <- moments[nrow(moments), ]
                Finalsize <- moments[nrow(moments), "finS"]
                mu <- mom$mu/Finalsize
                SS <- mom$SS/Finalsize
                w <- mom$w/Finalsize
                checkV <- (mom$checkV/Finalsize)
                within <- (mom$V/Finalsize)
                between <- (SS-mu^2)
                total <- within + between
                otherCheck = (w-mu^2)
                C1check <- mom$mu/(Finalsize - y0)
                C2check <- (mom$w + 2*y0*mu0)/(Finalsize - y0)
                return(data.frame(timeStep=timeStep
                                        , B0 = B0
                                        , finTime=finTime
                                        , frcIpeak=frcIpeak
                                        , Finalsize=Finalsize
                                        , muRc=mu
                                        , within=within
                                        , checkWithin = checkV
                                        , between=between
                                        , withinSS = w
                                        , totalVRc = total
                                        , totalVRc_simplified = otherCheck
                                        , totalKRc=total/mu^2
                                        , C1check=C1check
                                        , C2check=C2check
                         ))

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
#A better way for calculating incidence tk=(t_i + t_{i+1})/2

sim <- function(B0,  cars = 1, finTime=365,
                timeStep=0.1, dfun=boxcar,  t0 =0, 
                y0 = 1e-9){
  x0 <- 1-y0
  r0 <- 0
  cum0 <- y0
  infc <- c(y0,rep(0,cars-1))
  names(infc) <- paste0("y", 1:cars)
  y_init <- c(x = x0, infc, r=r0, cum = cum0)
  timePoints<- seq(from=0, to=t0 + finTime, by=timeStep)
  sim <- as.data.frame(ode(
    y = y_init
    , func=dfun
    , times=timePoints
    , atol = 1e-12
    , rtol = 1e-10
    , parms=list(B0=B0, cars = cars)
  ))
  sim <- sim[sim$time>=t0,]
  return(within(sim, {
    if (cars>1){
      y <- rowSums(as.data.frame(mget(paste0("y", 1:cars))))
    }else{
      y <- y1
    }
    inc <- c(NA,diff(cum))/timeStep
    mid_time <- c(NA, (head(time, -1) + tail(time, -1)) / 2)
    instantaneous_inc <- c(NA, diff(cum))    
  }))
}

cohortStatsRcPlot <- function(B0=1
			, cars = 1
			, cohortProp=0.6
			, timeStep=0.01
			, y0 = 1e-9
			, finTime = 365
			, stopTime = 100
			, dfun = boxcar
			, t0 = 0
															
){
	sdat<- sim(B0=B0,timeStep=timeStep, finTime=finTime, dfun=dfun, cars=cars, y0=y0, t0=t0
	)
	sfun <- approxfun(sdat$time, sdat$x, rule=2)
	maxCohort <- min(t0 + cohortProp*finTime, stopTime)
	cohorts <- with(sdat, time[time<=maxCohort])
	return(as.data.frame(t(
		sapply(cohorts, function(c) cCalc(sdat$time, cohort=c, sfun=sfun, tol=1e-4, cars=cars, B0 = B0
		))
	)
	)
	)
}
saveEnvironment()
