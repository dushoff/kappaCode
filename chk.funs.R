library(shellpipes)
## HERE


peakAssigner<-function(B0, y0 = 1e-9){
  SIRsim<-sim(B0=B0, finTime=100, timeStep=0.0001,  y0 = y0)
  idx<-which.max(SIRsim$inc)
  return(SIRsim[idx,"time"])
}

mderivs <- function(time, vars, parms){
  with(as.list(c(vars,parms)),{
 
  Ri <-flist$sfun(time) #fraction of susceptible
  dens <- exp(-(time - plist$T0))
  return(list(c(
      Ri
    , dens
    , Rc*dens
    , Rc*Rc*dens
        )))
  })
}

cMoments <- function(time, sfun, T0, B0){
  mom <- as.data.frame(ode(
    y=c(Rc=0, cumden=0, Rctot=0, RcSS=0)
    , func=mderivs
    , times=time
    , rtol = 1e-12
    , atol = 1e-14
    , parms=list(
        plist=list(T0=T0)
      , flist=list(sfun=sfun)
                )
                     )  )
  return(mom)
 }


cCalc <- function(time, cohort, sfun, tol=1e-4, stopTime, B0){
	sTime <- time[time>=cohort & time<=stopTime]
	moments <- cMoments(sTime, sfun, T0=cohort)
	mom <- moments[nrow(moments), ]
        stopifnot(mom$cumden >=0 && mom$cumden <=1)
        #attribute the last Rc to those remained infectious after the stop time
	Rctot = mom$Rctot + mom$Rc*(1.0-mom$cumden)
	RcSS = mom$RcSS + mom$Rc*mom$Rc*(1.0-mom$cumden)
	return(data.frame(
		  cohort=cohort
                , Rc=B0*Rctot
                , varRc=B0^2*(RcSS-Rctot^2)
		, RcSS =B0^2*RcSS
		, cumden=mom$cumden
		)        )	
		}
		
	


cohortStats <- function(B0 = 1
			, sdat = NULL
			, maxInfCohort = NULL
			, stopTime = NULL
			, timeStep
			){
	sfun <- approxfun(sdat$time, sdat$x, rule=2)
	#cohorts <- sdat[sdat$time<=maxInfCohort, "time"]
        cohorts <- seq(from = 0.0, to = maxInfCohort, by = timeStep )
        df <- map_dfr(cohorts, function(c){cCalc(sdat$time
                                                ,cohort=c
                                                ,sfun=sfun
						,tol=1e-4
						,stopTime = stopTime
						,B0 = B0
	                                          )}
	             )
return(df)
}

trunc <- function(B0=1
		 , nCohortPerIp=5000
		 , frcIpeak = NULL
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
	cStats <- cohortStats( B0 = B0
			       , sdat=sdat
			       , maxInfCohort=maxInfCohort 
			       , stopTime = frcIpeak*tpeak
                               , timeStep = timeStep
			      )
                ifun <- approxfun(sdat$time, B0*sdat$y*sdat$x, rule=2)
		rcfun <- approxfun(cStats$cohort, cStats$Rc, rule=2)
		varrcfun <- approxfun(cStats$cohort, cStats$varRc, rule=2)
		wssfun <- approxfun(cStats$cohort, cStats$RcSS, rule = 2)
		moments <- as.data.frame(ode(
			y=c(finS=0, mu=0, SS=0, V=0, w = 0, checkV = 0)
			, func=v1ODE
			, rtol = 1e-10
                        , atol = 1e-12
			, times= sdat[sdat$time <= maxInfCohort, "time"]   # cStats$cohort 
			, parms=list(ifun=ifun, rcfun=rcfun, varrcfun=varrcfun, wssfun = wssfun)
                                    ) 
                                      )
		mom <- moments[nrow(moments), ]
			mu <- mom$mu/mom$finS
			SS <- mom$SS/mom$finS
			w <- mom$w/mom$finS
			checkV <- (mom$checkV/mom$finS)
			within <- (mom$V/mom$finS)
			between <- (SS-mu^2)
			total = within + between
			otherCheck = (w-mu^2)
			Finalsize <- mom$finS
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

boxcar <- function(time, vars, parms){
    with(as.list(c(vars, parms)), {
    x <- exp(lx)
    y <- exp(ly)
    lydot <- B0*x - 1.0
    lxdot <- - B0*y
    cumdot <- B0*x*y
    out <- c(lxdot, lydot, cumdot)
    return(list(out))
    }
  )
}

sim <- function(y0=1e-9, B0=5,  finTime=20, timeStep=0.1){

  x0 <- 1 - y0
  y_init <- c(lx = log(x0)
            , ly = log(y0)
            , cum = 0
             )
  sim <- as.data.frame(ode(
		  y = y_init
	        , func=boxcar
		, times=seq(from=0, to=finTime, by=timeStep)
		, parms=list(B0=B0)
	                    )   )

  sim$x <- exp(sim$lx)
  sim$y <- exp(sim$ly)
  sim$inc <- c(NA, sim$cum[-1] - sim$cum[-nrow(sim)])
 return(sim[, c("time", "x", "y", "inc")])
 }





saveEnvironment()
