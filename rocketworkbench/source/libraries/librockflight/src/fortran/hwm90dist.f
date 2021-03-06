      SUBROUTINE GWS4(IYD,SEC,ALT,GLAT,GLONG,STL,F107A,F107,AP,W)
C      Horizontal wind model HWM90
C      A. E. HEDIN  (11/89);7/3/91(add SAVE)
C      Currently intended only for winds above 100 km.
C     INPUT:
C        IYD - YEAR AND DAY AS YYDDD
C        SEC - UT(SEC)
C        ALT - ALTITUDE(KM) 
C        GLAT - GEODETIC LATITUDE(DEG)
C        GLONG - GEODETIC LONGITUDE(DEG)
C        STL - LOCAL APPARENT SOLAR TIME(HRS)
C        F107A - 3 MONTH AVERAGE OF F10.7 FLUX
C        F107 - DAILY F10.7 FLUX FOR PREVIOUS DAY
C        AP - MAGNETIC INDEX(DAILY) OR WHEN SW(9)=-1.
C             AP(2)=CURRENT 3HR AP INDEX
C     Note:  Ut, Local Time, and Longitude are used independently in the
C            model and are not of equal importance for every situation.  
C            For the most physically realistic calculation these three
C            variables should be consistent (STL=SEC/3600+GLONG/15).
C      OUTPUT
C        W(1) = MERIDIONAL (m/sec + Northward)
C        W(2) = ZONAL (m/sec + Eastward)
C          ADDITIONAL COMMENTS
C               TO TURN ON AND OFF PARTICULAR VARIATIONS CALL TSELEC(SW)
C               WHERE SW IS A 25 ELEMENT ARRAY CONTAINING 0. FOR OFF, 1. 
C               FOR ON, OR 2. FOR MAIN EFFECTS OFF BUT CROSS TERMS ON
C               FOR THE FOLLOWING VARIATIONS
C               1 - F10.7 EFFECT ON MEAN  2 - TIME INDEPENDENT
C               3 - SYMMETRICAL ANNUAL    4 - SYMMETRICAL SEMIANNUAL
C               5 - ASYMMETRICAL ANNUAL   6 - ASYMMETRICAL SEMIANNUAL
C               7 - DIURNAL               8 - SEMIDIURNAL
C               9 - DAILY AP             10 - ALL UT/LONG EFFECTS
C              11 - LONGITUDINAL         12 - UT AND MIXED UT/LONG
C              13 - MIXED AP/UT/LONG     14 - TERDIURNAL
C              16 - ALL WINDF VAR        17 - ALL WZL VAR
C              18 - ALL UN1 VAR          19 - ALL WDZL VAR
C              24 - ALL B FIELDS (DIV)   25 - ALL C FIELDS (CURL)
C
C              To get current values of SW: CALL TRETRV(SW)
C
      DIMENSION AP(1),W(2),WINDF(2),WW(2)
      DIMENSION WZL(2),WDZL(2)
      DIMENSION ZN1(5),UN1(5,2),UGN1(2,2)
      COMMON/PARMW4/PWB(200),PWC(200),PWBL(150),PWCL(150),PWBLD(150),
     $ PWCLD(150),PB12(150),PC12(150),PB13(150),PC13(150),
     $ PB14(150),PC14(150),PB15(150),PC15(150),
     $ PB15D(150),PC15D(150)
      COMMON/CSW/SW(25),ISW,SWC(25)               
      COMMON/HWMC/WBT(2),WCT(2)
      COMMON/DATW4/ISD(3),IST(2),NAM(2)
      COMMON/DATIME/ISDATE(3),ISTIME(2),NAME(2)
      SAVE
      EXTERNAL GWS4BK
      DATA S/.016/,ZL/200./
      DATA MN1/5/,ZN1/200.,150.,130.,115.,100./
C      Put identification data into common/datime/
      DO 1 I=1,3
        ISDATE(I)=ISD(I)
    1 CONTINUE
      DO 2 I=1,2
        ISTIME(I)=IST(I)
        NAME(I)=NAM(I)
    2 CONTINUE
C
      YRD=IYD
C       EXOSPHERE WIND
      CALL GLBW4E(YRD,SEC,GLAT,GLONG,STL,F107A,F107,AP,PWB,PWC,WINDF)
      WINDF(1)=SW(16)*WINDF(1)
      WINDF(2)=SW(16)*WINDF(2)
C       WIND  AT ZL (200)
      CALL GLOBW4(PWBL,PWCL,WW)
      WZL(1)=(PWBL(1)*WINDF(1)+WW(1))*SW(17)*SW(18)
      WZL(2)=(PWBL(1)*WINDF(2)+WW(2))*SW(17)*SW(18)
      UN1(1,1)=WZL(1)
      UN1(1,2)=WZL(2)
C       WIND DERIVATIVE AT ZL
      WW(1)=0
      WW(2)=0
      CALL GLOBW4(PWBLD,PWCLD,WW)
      WDZL(1)=(PWBLD(1)*WINDF(1)+WW(1))*SW(19)*SW(18)
      WDZL(2)=(PWBLD(1)*WINDF(2)+WW(2))*SW(19)*SW(18)
      UGN1(1,1)=WDZL(1)*S
      UGN1(1,2)=WDZL(2)*S
C
      IF(ALT.GE.ZL) GOTO 90
C
C        WIND AT ZN2 (150)
      CALL GLOBW4(PB12,PC12,WW)
      UN1(2,1)=(PB12(1)*WINDF(1)+WW(1))*SW(18)
      UN1(2,2)=(PB12(1)*WINDF(2)+WW(2))*SW(18)
C        WIND AT ZN3 (130)
      CALL GLOBW4(PB13,PC13,WW)
      UN1(3,1)=WW(1)*SW(18)
      UN1(3,2)=WW(2)*SW(18)
C        WIND AT ZN4 (115)
      CALL GLOBW4(PB14,PC14,WW)
      UN1(4,1)=WW(1)*SW(18)
      UN1(4,2)=WW(2)*SW(18)
C        WIND AT ZN5 (100)
      CALL GLOBW4(PB15,PC15,WW)
      UN1(5,1)=WW(1)*SW(18)
      UN1(5,2)=WW(2)*SW(18)
C         WIND DERIVATIVE AT ZN5 (100)
      CALL GLOBW4(PB15D,PC15D,WW)
      UGN1(2,1)=WW(1)*SW(18)
      UGN1(2,2)=WW(2)*SW(18)
   90 CONTINUE
C       WIND AT ALTITUDE
      W(1)= WPROF4(ALT,ZL,S,WINDF(1),WZL(1),WDZL(1),
     $  MN1,ZN1,UN1(1,1),UGN1(1,1))
      W(2)= WPROF4(ALT,ZL,S,WINDF(2),WZL(2),WDZL(2),
     $  MN1,ZN1,UN1(1,2),UGN1(1,2))
C      TYPE*,'GWSB',W(1),WINDF(1),WZL(1),WDZL(1),
C     $    (UN1(J,1),J=1,MN1),UGN1(1,1),UGN1(2,1)
C      TYPE*,'WSC',W(2),WINDF(2),WZL(2),WDZL(2),
C     $    (UN1(J,2),J=1,MN1),UGN1(1,2),UGN1(2,2)
      RETURN
      END
C-----------------------------------------------------------------------
      FUNCTION WPROF4(Z,ZL,S,UINF,ULB,ULBD,MN1,ZN1,UN1,UGN1)
C      Wind at altitude Z based on values at nodes
      DIMENSION ZN1(MN1),UN1(MN1),UGN1(2),XS(10),YS(10),Y2OUT(10)
      SAVE
      IF(Z.GE.ZL) THEN
        X=S*(Z-ZL)
        F=EXP(-X)
C         Modified Bates profile
        WPROF4=UINF+(ULB-UINF)*F+(ULB-UINF+ULBD)*X*F
        RETURN
      ENDIF
      IF(Z.GE.ZN1(MN1)) THEN
        MN=MN1
        Z1=ZN1(1)
        Z2=ZN1(MN)
        ZDIF=Z2-Z1
C        Set up for spline interpolation
        DO 10 K=1,MN
          XS(K)=(ZN1(K)-Z1)/ZDIF
          YS(K)=UN1(K)
   10   CONTINUE
        YD1=UGN1(1)*ZDIF
        YD2=UGN1(2)*ZDIF
        CALL SPLINE(XS,YS,MN,YD1,YD2,Y2OUT)
        X=(Z-Z1)/ZDIF
        CALL SPLINT(XS,YS,Y2OUT,MN,X,Y)
        WPROF4=Y
        RETURN
      ENDIF
      RETURN
      END
C-----------------------------------------------------------------------
      SUBROUTINE GLBW4E(YRD,SEC,LAT,LONG,STL,F107A,F107,AP,PB,PC,WW)
C       CALCULATE G(L) FUNCTION 
C       Upper Thermosphere Parameters
      REAL LAT,LONG
      DIMENSION WB(2,15),WC(2,15),PB(200),PC(200),WW(2)
      DIMENSION AP(2),SV(25)
      COMMON/CSW/SW(25),ISW,SWC(25)
      COMMON/HWMC/WBT(2),WCT(2)
      COMMON/VPOLY/BT(20,20),BP(20,20),CSTL,SSTL,C2STL,S2STL,
     $ C3STL,S3STL,IYR,DAY,DF,DFA,DFC,APD,APDF,APDFC,APT,SLT
      SAVE
      DATA DGTR/.017453/,SR/7.2722E-5/,HR/.2618/,DR/1.72142E-2/
      DATA NSW/14/,WB/30*0/,WC/30*0/,TLL/-99./,XL/-999./,XLONG/-999./
      DATA PB14/-1./,PB18/-1./
      DATA SV/25*1./,SW9/1./
      G0(A)=(A-4.+(PB(26)-1.)*(A-4.+(EXP(-ABS(PB(25))*(A-4.))-1.)/
     * ABS(PB(25))))
      IF(ISW.NE.64999) CALL TSELEC(SV)
      DO 10 J=1,14
        WB(1,J)=0
        WB(2,J)=0
        WC(1,J)=0
        WC(2,J)=0
   10 CONTINUE
      SLT=STL
      IF(SW(9).GT.0) SW9=1.
      IF(SW(9).LT.0) SW9=-1.
      IYR = YRD/1000.
      DAY = YRD - IYR*1000.
      IF(XL.NE.LAT) THEN
C         Calculate vector spherical harmonics
        CALL VSPHER(LAT,12,3,BT,BP,20)
        XL=LAT
        SLAT=SIN(DGTR*LAT)
      ENDIF
      IF(TLL.NE.STL)  THEN
        SSTL = SIN(HR*STL)
        CSTL = COS(HR*STL)
        S2STL = SIN(2.*HR*STL)
        C2STL = COS(2.*HR*STL)
        S3STL = SIN(3.*HR*STL)
        C3STL = COS(3.*HR*STL)
        TLL = STL
      ENDIF
      IF(DAY.NE.DAYL.OR.PB(14).NE.PB14) CD14=COS(DR*(DAY-PB(14)))
      IF(DAY.NE.DAYL.OR.PB(18).NE.PB18) CD18=COS(2.*DR*(DAY-PB(18)))
      DAYL=DAY
      PB14=PB(14)
      PB18=PB(18)
      IF(XLONG.NE.LONG) THEN
        SLONG=SIN(DGTR*LONG)
        CLONG=COS(DGTR*LONG)
        S2LONG=SIN(2.*DGTR*LONG)
        C2LONG=COS(2.*DGTR*LONG)
        XLONG=LONG
      ENDIF
C       F10.7 EFFECT
      DF=F107-F107A
      DFA=F107A-150.
      DFC=F107A-150.+PB(20)*DF
C       TIME INDEPENDENT
      F1B=1.+PB(22)*DFC*SWC(1)
      WB(1,2)=(PB(2)*BT(3,1)+PB(3)*BT(5,1)+PB(23)*BT(7,1))*F1B
      WB(2,2)=0.
      F1C=1.+PC(22)*DFC*SWC(1)
      WC(1,2)=0.
      WC(2,2)=-(PC(2)*BT(2,1)+PC(3)*BT(4,1)+PC(23)*BT(6,1))*F1C
     $ -(PC(27)*BT(3,1)+PC(15)*BT(5,1)+PC(60)*BT(7,1)
     $ +PC(161)*BT(9,1)+PC(162)*BT(11,1)+PC(163)*BT(13,1))*F1C
C       SYMMETRICAL ANNUAL
C        none
C       SYMMETRICAL SEMIANNUAL
      WB(1,4)=(PB(16)*BT(3,1)+PB(17)*BT(5,1))*CD18
      WB(2,4)=0
      WC(1,4)=0
      WC(2,4)=-(PC(16)*BT(2,1)+PC(17)*BT(4,1))*CD18
C       ASYMMETRICAL ANNUAL
      F5B=1.+PB(48)*DFC*SWC(1)
      WB(1,5)=(PB(10)*BT(2,1)+PB(11)*BT(4,1))*CD14*F5B
      WB(2,5)=0
      F5C=1.+PC(48)*DFC*SWC(1)
      WC(1,5)=0
      WC(2,5)=-(PC(10)*BT(3,1)+PC(11)*BT(5,1))*CD14*F5C
C       ASYMMETRICAL SEMIANNUAL
C         none
C       DIURNAL      
      IF(SW(7).EQ.0) GOTO 200
      F7B=1.+PB(50)*DFC*SWC(1)
      F75B=1.+PB(83)*DFC*SWC(1)
      WB(1,7)=(PB(7)*BT(2,2)+PB(8)*BT(4,2)+PB(29)*BT(6,2)
     $ +PB(142)*BT(8,2)+PB(144)*BT(10,2)
     $  +PB(182)*BT(3,2)+PB(184)*BT(5,2)
     $  )*SSTL*F7B
     $ +(PB(13)*BT(3,2)+PB(146)*BT(5,2))
     $    *CD14*SSTL*F75B*SWC(5)
     $ +(PB(171)*BT(2,2)+PB(173)*BT(4,2))
     $    *CD18*SSTL*F75B*SWC(4)
     $ + (PB(4)*BT(2,2)+PB(5)*BT(4,2)+PB(28)*BT(6,2)
     $ +PB(141)*BT(8,2)+PB(143)*BT(10,2)
     $  +PB(181)*BT(3,2)+PB(183)*BT(5,2)
     $  )*CSTL*F7B
     $ +(PB(12)*BT(3,2)+PB(145)*BT(5,2))
     $      *CD14*CSTL*F75B*SWC(5)
     $ +(PB(170)*BT(2,2)+PB(172)*BT(4,2))
     $    *CD18*CSTL*F75B*SWC(4)
      WB(2,7)=-(PB(4)*BP(2,2)+PB(5)*BP(4,2)+PB(28)*BP(6,2)
     $   +PB(141)*BP(8,2)+PB(143)*BP(10,2)
     $   +PB(181)*BP(3,2)+PB(183)*BP(5,2)
     $  )*SSTL*F7B
     $ -(PB(12)*BP(3,2)+PB(145)*BP(5,2))
     $    *CD14*SSTL*F75B*SWC(5)
     $ -(PB(170)*BP(2,2)+PB(172)*BP(4,2))
     $    *CD18*SSTL*F75B*SWC(4)
     $ + (PB(7)*BP(2,2)+PB(8)*BP(4,2)+PB(29)*BP(6,2)
     $   +PB(142)*BP(8,2)+PB(144)*BP(10,2)
     $   +PB(182)*BP(3,2)+PB(184)*BP(5,2)
     $  )*CSTL*F7B
     $ +(PB(13)*BP(3,2)+PB(146)*BP(5,2))
     $    *CD14*CSTL*F75B*SWC(5)
     $ +(PB(171)*BP(2,2)+PB(173)*BP(4,2))
     $    *CD18*CSTL*F75B*SWC(4)
      F7C=1.+PC(50)*DFC*SWC(1)
      F75C=1.+PC(83)*DFC*SWC(1)
      WC(1,7)=-(PC(4)*BP(3,2)+PC(5)*BP(5,2)+PC(28)*BP(7,2)
     $   +PC(141)*BP(9,2)+PC(143)*BP(11,2)
     $   +PC(181)*BP(2,2)+PC(183)*BP(4,2)+PC(185)*BP(6,2)
     $   +PC(187)*BP(8,2)+PC(189)*BP(10,2)
     $  )*SSTL*F7C
     $ -(PC(12)*BP(2,2)+PC(145)*BP(4,2))
     $    *CD14*SSTL*F75C*SWC(5)
     $ -(PC(170)*BP(3,2)+PC(172)*BP(5,2))
     $    *CD18*SSTL*F75C*SWC(4)
     $ +(PC(7)*BP(3,2)+PC(8)*BP(5,2)+PC(29)*BP(7,2)
     $ +PC(142)*BP(9,2)+PC(144)*BP(11,2)
     $ +PC(182)*BP(2,2)+PC(184)*BP(4,2)+PC(186)*BP(6,2)
     $ +PC(188)*BP(8,2)+PC(190)*BP(10,2)
     $  )*CSTL*F7C
     $ +(PC(13)*BP(2,2)+PC(146)*BP(4,2))
     $     *CD14*CSTL*F75C*SWC(5)
     $ +(PC(171)*BP(3,2)+PC(173)*BP(5,2))
     $    *CD18*CSTL*F75C*SWC(4)
      WC(2,7)=-(PC(7)*BT(3,2)+PC(8)*BT(5,2)+PC(29)*BT(7,2)
     $ +PC(142)*BT(9,2)+PC(144)*BT(11,2)
     $ +PC(182)*BT(2,2)+PC(184)*BT(4,2)+PC(186)*BT(6,2)
     $ +PC(188)*BT(8,2)+PC(190)*BT(10,2)
     $  )*SSTL*F7C
     $ -(PC(13)*BT(2,2)+PC(146)*BT(4,2))
     $    *CD14*SSTL*F75C*SWC(5)
     $ -(PC(171)*BT(3,2)+PC(173)*BT(5,2))
     $    *CD18*SSTL*F75C*SWC(4)
     $ -(PC(4)*BT(3,2)+PC(5)*BT(5,2)+PC(28)*BT(7,2)
     $ +PC(141)*BT(9,2)+PC(143)*BT(11,2)
     $ +PC(181)*BT(2,2)+PC(183)*BT(4,2)+PC(185)*BT(6,2)
     $ +PC(187)*BT(8,2)+PC(189)*BT(10,2)
     $  )*CSTL*F7C
     $ -(PC(12)*BT(2,2)+PC(145)*BT(4,2))
     $    *CD14*CSTL*F75C*SWC(5)
     $ -(PC(170)*BT(3,2)+PC(172)*BT(5,2))
     $    *CD18*CSTL*F75C*SWC(4)
  200 CONTINUE
C       SEMIDIURNAL
      IF(SW(8).EQ.0) GOTO 210
      F8B=1.+PB(90)*DFC*SWC(1)
      WB(1,8)=(PB(9)*BT(3,3)+PB(43)*BT(5,3)
     $   +PB(111)*BT(7,3)
     $   +(PB(34)*BT(4,3)+PB(148)*BT(6,3))*CD14*SWC(5)
     $   +(PB(134)*BT(3,3))*CD18*SWC(4) 
     $   +PB(152)*BT(4,3)+PB(154)*BT(6,3)+PB(156)*BT(8,3)
     $   +PB(158)*BT(10,3)
     $  )*S2STL*F8B
     $ +(PB(6)*BT(3,3)+PB(42)*BT(5,3)
     $   +PB(110)*BT(7,3)
     $   +(PB(24)*BT(4,3)+PB(147)*BT(6,3))*CD14*SWC(5)
     $   +(PB(135)*BT(3,3))*CD18*SWC(4)
     $   +PB(151)*BT(4,3)+PB(153)*BT(6,3)+PB(155)*BT(8,3)
     $   +PB(157)*BT(10,3)
     $  )*C2STL*F8B
      WB(2,8)=-(PB(6)*BP(3,3)+PB(42)*BP(5,3)
     $   +PB(110)*BP(7,3)
     $   +(PB(24)*BP(4,3)+PB(147)*BP(6,3))*CD14*SWC(5)
     $   +(PB(135)*BP(3,3))*CD18*SWC(4)
     $   +PB(151)*BP(4,3)+PB(153)*BP(6,3)+PB(155)*BP(8,3)
     $   +PB(157)*BP(10,3)
     $  )*S2STL*F8B
     $   + (PB(9)*BP(3,3)+PB(43)*BP(5,3)
     $   +PB(111)*BP(7,3)
     $   +(PB(34)*BP(4,3)+PB(148)*BP(6,3))*CD14*SWC(5)
     $   +(PB(134)*BP(3,3))*CD18*SWC(4)
     $   +PB(152)*BP(4,3)+PB(154)*BP(6,3)+PB(156)*BP(8,3)
     $   +PB(158)*BP(10,3)
     $  )*C2STL*F8B
      F8C=1.+PC(90)*DFC*SWC(1)
      WC(1,8)=-(PC(6)*BP(4,3)+PC(42)*BP(6,3)
     $   +PC(110)*BP(8,3)
     $   +(PC(24)*BP(3,3)+PC(147)*BP(5,3))*CD14*SWC(5)
     $   +(PC(135)*BP(4,3))*CD18*SWC(4)
     $   +PC(151)*BP(3,3)+PC(153)*BP(5,3)+PC(155)*BP(7,3)
     $   +PC(157)*BP(9,3)
     $  )*S2STL*F8C
     $ +(PC(9)*BP(4,3)+PC(43)*BP(6,3)
     $   +PC(111)*BP(8,3)
     $   +(PC(34)*BP(3,3)+PC(148)*BP(5,3))*CD14*SWC(5)
     $   +(PC(134)*BP(4,3))*CD18*SWC(4)
     $   +PC(152)*BP(3,3)+PC(154)*BP(5,3)+PC(156)*BP(7,3)
     $   +PC(158)*BP(9,3)
     $  )*C2STL*F8C
      WC(2,8)=-(PC(9)*BT(4,3)+PC(43)*BT(6,3)
     $   +PC(111)*BT(8,3)
     $   +(PC(34)*BT(3,3)+PC(148)*BT(5,3))*CD14*SWC(5)
     $   +(PC(134)*BT(4,3))*CD18*SWC(4)
     $   +PC(152)*BT(3,3)+PC(154)*BT(5,3)+PC(156)*BT(7,3)
     $   +PC(158)*BT(9,3)
     $  )*S2STL*F8C
     $ - (PC(6)*BT(4,3)+PC(42)*BT(6,3)
     $   +PC(110)*BT(8,3)
     $   +(PC(24)*BT(3,3)+PC(147)*BT(5,3))*CD14*SWC(5)
     $   +(PC(135)*BT(4,3))*CD18*SWC(4)
     $   +PC(151)*BT(3,3)+PC(153)*BT(5,3)+PC(155)*BT(7,3)
     $   +PC(157)*BT(9,3)
     $  )*C2STL*F8C
  210 CONTINUE
C        TERDIURNAL
      IF(SW(14).EQ.0) GOTO 220
      F14B=1.+PB(100)*DFC*SWC(1)
      WB(1,14)=(PB(40)*BT(4,4)+PB(149)*BT(6,4)
     $   +PB(114)*BT(8,4)
     $   +(PB(94)*BT(5,4)+PB(47)*BT(7,4))*CD14*SWC(5)
     $  )*S3STL*F14B
     $ + (PB(41)*BT(4,4)+PB(150)*BT(6,4)
     $   +PB(115)*BT(8,4)
     $   +(PB(95)*BT(5,4)+PB(49)*BT(7,4))*CD14*SWC(5)
     $  )*C3STL*F14B
      WB(2,14)=-(PB(41)*BP(4,4)+PB(150)*BP(6,4)
     $   +PB(115)*BP(8,4)
     $   +(PB(95)*BP(5,4)+PB(49)*BP(7,4))*CD14*SWC(5)
     $  )*S3STL*F14B
     $ + (PB(40)*BP(4,4)+PB(149)*BP(6,4)
     $   +PB(114)*BP(8,4)
     $   +(PB(94)*BP(5,4)+PB(47)*BP(7,4))*CD14*SWC(5)
     $  )*C3STL*F14B
      F14C=1.+PC(100)*DFC*SWC(1)
      WC(1,14)=-(PC(41)*BP(5,4)+PC(150)*BP(7,4)
     $   +PC(115)*BP(9,4)
     $   +(PC(95)*BP(4,4)+PC(49)*BP(6,4))*CD14*SWC(5)
     $  )*S3STL*F14C
     $ + (PC(40)*BP(5,4)+PC(149)*BP(7,4)
     $   +PC(114)*BP(9,4)
     $   +(PC(94)*BP(4,4)+PC(47)*BP(6,4))*CD14*SWC(5)
     $  )*C3STL*F14C
      WC(2,14)=-(PC(40)*BT(5,4)+PC(149)*BT(7,4)
     $   +PC(114)*BT(9,4)
     $   +(PC(94)*BT(4,4)+PC(47)*BT(6,4))*CD14*SWC(5)
     $  )*S3STL*F14C
     $ - (PC(41)*BT(5,4)+PC(150)*BT(7,4)
     $   +PC(115)*BT(9,4)
     $   +(PC(95)*BT(4,4)+PC(49)*BT(6,4))*CD14*SWC(5)
     $  )*C3STL*F14C
  220 CONTINUE
C        MAGNETIC ACTIVITY
      IF(SW(9).EQ.0.) GOTO 40
      IF(SW9.EQ.-1.) GOTO 30
C           daily AP
      APD=AP(1)-4.
      APDF=(APD+(PB(45)-1.)*(APD+(EXP(-PB(44)*APD)-1.)/PB(44)))
C      APDFC=(APD+(PC(45)-1.)*(APD+(EXP(-PC(44)*APD)-1.)/PC(44)))
      APDFC=APDF
      WB(1,9)=(PB(46)*BT(3,1)+PB(35)*BT(5,1)+PB(33)*BT(7,1))*APDF
     $  +(PB(175)*BT(3,3)+PB(177)*BT(5,3))*S2STL*APDF
     $  +(PB(174)*BT(3,3)+PB(176)*BT(5,3))*C2STL*APDF
      WB(2,9)=0                                              
     $  -(PB(174)*BP(3,3)+PB(176)*BP(5,3))*S2STL*APDF
     $  +(PB(175)*BP(3,3)+PB(177)*BP(5,3))*C2STL*APDF
      WC(1,9)=SWC(7)*WC(1,7)*PC(122)*APDFC
     $  -(PC(174)*BP(4,3)+PC(176)*BP(6,3))*S2STL*APDFC
     $  +(PC(175)*BP(4,3)+PC(177)*BP(6,3))*C2STL*APDFC
      WC(2,9)=-(PC(46)*BT(2,1)+PC(35)*BT(4,1)+PC(33)*BT(6,1))*APDFC
     $ +SWC(7)*WC(2,7)*PC(122)*APDFC
     $ -(PC(175)*BT(4,3)+PC(177)*BT(6,3))*S2STL*APDFC
     $ -(PC(174)*BT(4,3)+PC(176)*BT(6,3))*C2STL*APDFC
      GO TO 40
   30 CONTINUE
      IF(PB(25).LT.1.E-4) PB(25)=1.E-4
      APT=G0(AP(2))
      WB(1,9)=(PB(97)*BT(3,1)+PB(55)*BT(5,1)+PB(51)*BT(7,1))*APT
     $  +(PB(160)*BT(3,3)+PB(179)*BT(5,3))*S2STL*APT
     $  +(PB(159)*BT(3,3)+PB(178)*BT(5,3))*C2STL*APT
      WB(2,9)=0
     $  -(PB(159)*BP(3,3)+PB(178)*BP(5,3))*S2STL*APT
     $  +(PB(160)*BP(3,3)+PB(179)*BP(5,3))*C2STL*APT
      WC(1,9)=SWC(7)*WC(1,7)*PC(129)*APT
     $  -(PC(159)*BP(4,3)+PC(178)*BP(6,3))*S2STL*APT
     $  +(PC(160)*BP(4,3)+PC(179)*BP(6,3))*C2STL*APT
      WC(2,9)=-(PC(97)*BT(2,1)+PC(55)*BT(4,1)+PC(51)*BT(6,1))*APT
     $ +SWC(7)*WC(2,7)*PC(129)*APT
     $ -(PC(160)*BT(4,3)+PC(179)*BT(6,3))*S2STL*APT
     $ -(PC(159)*BT(4,3)+PC(178)*BT(6,3))*C2STL*APT
  40  CONTINUE
      IF(SW(10).EQ.0) GOTO 49
C        LONGITUDINAL
      DBASY1=1.+PB(199)*SLAT
      DBASY2=1.+PB(200)*SLAT
      F11B=1.+PB(81)*DFC*SWC(1)
      WB(1,11)=(PB(91)*BT(3,2)+PB(92)*BT(5,2)+PB(93)*BT(7,2))
     $  *SLONG*DBASY1*F11B
     $ + (PB(65)*BT(3,2)+PB(66)*BT(5,2)+PB(67)*BT(7,2))
     $  *CLONG*DBASY1*F11B
     $  +(PB(191)*BT(3,3)+PB(193)*BT(5,3)+PB(195)*BT(7,3)
     $   +PB(197)*BT(9,3)
     $  )*S2LONG*DBASY2*F11B
     $ + (PB(192)*BT(3,3)+PB(194)*BT(5,3)+PB(196)*BT(7,3)
     $    +PB(198)*BT(9,3)
     $  )*C2LONG*DBASY2*F11B
      WB(2,11)=-(PB(65)*BP(3,2)+PB(66)*BP(5,2)+PB(67)*BP(7,2))
     $  *SLONG*DBASY1*F11B
     $ + (PB(91)*BP(3,2)+PB(92)*BP(5,2)+PB(93)*BP(7,2))
     $  *CLONG*DBASY1*F11B
     $ -(PB(192)*BP(3,3)+PB(194)*BP(5,3)+PB(196)*BP(7,3)
     $   +PB(198)*BP(9,3)
     $  )*S2LONG*DBASY2*F11B
     $ + (PB(191)*BP(3,3)+PB(193)*BP(5,3)+PB(195)*BP(7,3)
     $    +PB(197)*BP(9,3)
     $  )*C2LONG*DBASY2*F11B
      DCASY1=1.+PC(199)*SLAT
      DCASY2=1.+PC(200)*SLAT
      F11C=1.+PC(81)*DFC*SWC(1)
      WC(1,11)=-(PC(65)*BP(2,2)+PC(66)*BP(4,2)+PC(67)*BP(6,2)
     $ +PC(73)*BP(8,2)+PC(74)*BP(10,2)
     $  )*SLONG*DCASY1*F11C
     $ + (PC(91)*BP(2,2)+PC(92)*BP(4,2)+PC(93)*BP(6,2)
     $ +PC(87)*BP(8,2)+PC(88)*BP(10,2)
     $  )*CLONG*DCASY1*F11C
     $  -(PC(192)*BP(4,3)+PC(194)*BP(6,3)+PC(196)*BP(8,3)
     $ +PC(198)*BP(10,3)
     $  )*S2LONG*DCASY2*F11C
     $ + (PC(191)*BP(4,3)+PC(193)*BP(6,3)+PC(195)*BP(8,3)
     $ +PC(197)*BP(10,3)
     $  )*C2LONG*DCASY2*F11C
      WC(2,11)=-(PC(91)*BT(2,2)+PC(92)*BT(4,2)+PC(93)*BT(6,2)
     $ +PC(87)*BT(8,2)+PC(88)*BT(10,2)
     $  )*SLONG*DCASY1*F11C
     $ - (PC(65)*BT(2,2)+PC(66)*BT(4,2)+PC(67)*BT(6,2)
     $ +PC(73)*BT(8,2)+PC(74)*BT(10,2)
     $  )*CLONG*DCASY1*F11C
     $  -(PC(191)*BT(4,3)+PC(193)*BT(6,3)+PC(195)*BT(8,3)
     $ +PC(197)*BT(10,3)
     $  )*S2LONG*DCASY2*F11C
     $ - (PC(192)*BT(4,3)+PC(194)*BT(6,3)+PC(196)*BT(8,3)
     $ +PC(198)*BT(10,3)
     $  )*C2LONG*DCASY2*F11C
C       UT & MIXED UT/LONG
      UTBASY=1.
      F12B=1.+PB(82)*DFC*SWC(1)
      WB(1,12)=(PB(69)*BT(2,1)+PB(70)*BT(4,1)+PB(71)*BT(6,1)
     $ +PB(116)*BT(8,1)+PB(117)*BT(10,1)+PB(118)*BT(12,1)
     $  )*COS(SR*(SEC-PB(72)))*UTBASY*F12B
     $ + (PB(77)*BT(4,3)+PB(78)*BT(6,3)+PB(79)*BT(8,3))
     $  *COS(SR*(SEC-PB(80))+2.*DGTR*LONG)*UTBASY*F12B
      WB(2,12)=(PB(77)*BP(4,3)+PB(78)*BP(6,3)+PB(79)*BP(8,3))
     $  *COS(SR*(SEC-PB(80)+21600.)+2.*DGTR*LONG)
     $    *UTBASY*F12B
      UTCASY=1.
      F12C=1.+PC(82)*DFC*SWC(1)
      WC(1,12)=(PC(77)*BP(3,3)+PC(78)*BP(5,3)+PC(79)*BP(7,3)
     $ +PC(165)*BP(9,3)+PC(166)*BP(11,3)+PC(167)*BP(13,3)
     $  )*COS(SR*(SEC-PC(80))+2.*DGTR*LONG)*UTCASY*F12C
      WC(2,12)=-(PC(69)*BT(3,1)+PC(70)*BT(5,1)+PC(71)*BT(7,1)
     $ +PC(116)*BT(9,1)+PC(117)*BT(11,1)+PC(118)*BT(13,1)
     $  )*COS(SR*(SEC-PC(72)))*UTCASY*F12C
     $ + (PC(77)*BT(3,3)+PC(78)*BT(5,3)+PC(79)*BT(7,3)
     $ +PC(165)*BT(9,3)+PC(166)*BT(11,3)+PC(167)*BT(13,3)
     $  )*COS(SR*(SEC-PC(80)+21600.)+2.*DGTR*LONG)
     $   *UTCASY*F12C

      IF(SW9.EQ.-1.) GO TO 45
      WB(1,13)=
     $ (PB(61)*BT(3,2)+PB(62)*BT(5,2)+PB(63)*BT(7,2))
     $  *COS(DGTR*(LONG-PB(64)))*APDF*SWC(11)+
     $  (PB(84)*BT(2,1)+PB(85)*BT(4,1)+PB(86)*BT(6,1))
     $  *COS(SR*(SEC-PB(76)))*APDF*SWC(12)
      WB(2,13)=(PB(61)*BP(3,2)+PB(62)*BP(5,2)+PB(63)*BP(7,2))
     $  *COS(DGTR*(LONG-PB(64)+90.))*APDF*SWC(11)
      WC(1,13)=SWC(11)*WC(1,11)*PC(61)*APDFC
     $ +SWC(12)*WC(1,12)*PC(84)*APDFC
      WC(2,13)=SWC(11)*WC(2,11)*PC(61)*APDFC
     $ +SWC(12)*WC(2,12)*PC(84)*APDFC
      GOTO 48
   45 CONTINUE
      WB(1,13)=
     $  (PB(53)*BT(3,2)+PB(99)*BT(5,2)+PB(68)*BT(7,2))
     $  *COS(DGTR*(LONG-PB(98)))*APT*SWC(11)+
     $  (PB(56)*BT(2,1)+PB(57)*BT(4,1)+PB(58)*BT(6,1))
     $  *COS(SR*(SEC-PB(59)))*APT*SWC(12)
      WB(2,13)=(PB(53)*BP(3,2)+PB(99)*BP(5,2)+PB(68)*BP(7,2))
     $  *COS(DGTR*(LONG-PB(98)+90.))*APT*SWC(11)
      WC(1,13)=SWC(11)*WC(1,11)*PC(53)*APT
     $ +SWC(12)*WC(1,12)*PC(56)*APT
      WC(2,13)=SWC(11)*WC(2,11)*PC(53)*APT
     $ +SWC(12)*WC(2,12)*PC(56)*APT
   48 CONTINUE
   49 CONTINUE
      WBT(1)=0             
      WBT(2)=0
      WCT(1)=0
      WCT(2)=0                                 
C       SUM WINDS AND CHANGE MERIDIONAL SIGN TO + NORTH
      DO 50 K=1,NSW
        WBT(1)=WBT(1)-ABS(SW(K))*WB(1,K)
        WCT(1)=WCT(1)-ABS(SW(K))*WC(1,K)
        WBT(2)=WBT(2)+ABS(SW(K))*WB(2,K)
        WCT(2)=WCT(2)+ABS(SW(K))*WC(2,K)
   50 CONTINUE
      WW(1)=WBT(1)*SW(24)+WCT(1)*SW(25)
      WW(2)=WBT(2)*SW(24)+WCT(2)*SW(25)
      RETURN
      END
C-----------------------------------------------------------------------
      SUBROUTINE GLOBW4(PB,PC,WW)
C       CALCULATE G(L) FUNCTION 
C       Lower Thermosphere Parameters
C       Assumes GLBW4E has been called
      DIMENSION WB(2,15),WC(2,15),PB(150),PC(150),WW(2)
      COMMON/CSW/SW(25),ISW,SWC(25)
      COMMON/HWMC/WBT(2),WCT(2)
      COMMON/VPOLY/BT(20,20),BP(20,20),CSTL,SSTL,C2STL,S2STL,
     $ C3STL,S3STL,IYR,DAY,DF,DFA,DFC,APD,APDF,APDFC,APT,STL
      SAVE
      DATA DGTR/.017453/,SR/7.2722E-5/,HR/.2618/,DR/1.72142E-2/
      DATA PB14/-1./,PB18/-1./
      DATA NSW/14/
      DATA SW9/1./
      DO 10 J=1,NSW
        WB(1,J)=0
        WB(2,J)=0
        WC(1,J)=0
        WC(2,J)=0
   10 CONTINUE
      IF(SW(9).GT.0) SW9=1.
      IF(SW(9).LT.0) SW9=-1.
      IF(DAY.NE.DAYL.OR.PB(14).NE.PB14) CD14=COS(DR*(DAY-PB(14)))
      IF(DAY.NE.DAYL.OR.PB(18).NE.PB18) CD18=COS(2.*DR*(DAY-PB(18)))
      DAYL=DAY
      PB14=PB(14)
      PB18=PB(18)
C       TIME INDEPENDENT
      F1B=1.
      WB(1,2)=(PB(2)*BT(3,1)+PB(3)*BT(5,1)+PB(23)*BT(7,1))*F1B
      WB(2,2)=0.
      F1C=1.
      WC(1,2)=0.
      WC(2,2)=-(PC(2)*BT(2,1)+PC(3)*BT(4,1)+PC(23)*BT(6,1))*F1C
     $ -(PC(27)*BT(3,1)+PC(15)*BT(5,1)+PC(60)*BT(7,1))*F1C
C       SYMMETRICAL ANNUAL
C       SYMMETRICAL SEMIANNUAL
      WB(1,4)=(PB(16)*BT(3,1)+PB(17)*BT(5,1))*CD18
      WB(2,4)=0
      WC(1,4)=0
      WC(2,4)=-(PC(16)*BT(2,1)+PC(17)*BT(4,1))*CD18
C       ASYMMETRICAL ANNUAL
      F5B=1.
      WB(1,5)=(PB(10)*BT(2,1)+PB(11)*BT(4,1))*CD14*F5B
      WB(2,5)=0
      F5C=1.
      WC(1,5)=0
      WC(2,5)=-(PC(10)*BT(3,1)+PC(11)*BT(5,1))*CD14*F5C
C       ASYMMETRICAL SEMIANNUAL
C       DIURNAL      
      IF(SW(7).EQ.0) GOTO 200
      F7B=1.
      F75B=1.
      WB(1,7)=(PB(7)*BT(2,2)+PB(8)*BT(4,2)+PB(29)*BT(6,2)
     $  )*SSTL*F7B
     $ +(PB(13)*BT(3,2)+PB(146)*BT(5,2))
     $    *CD14*SSTL*F75B*SWC(5)
     $ + (PB(4)*BT(2,2)+PB(5)*BT(4,2)+PB(28)*BT(6,2)
     $  )*CSTL*F7B
     $ +(PB(12)*BT(3,2)+PB(145)*BT(5,2))
     $      *CD14*CSTL*F75B*SWC(5)
      WB(2,7)=-(PB(4)*BP(2,2)+PB(5)*BP(4,2)+PB(28)*BP(6,2)
     $  )*SSTL*F7B
     $ -(PB(12)*BP(3,2)+PB(145)*BP(5,2))
     $    *CD14*SSTL*F75B*SWC(5)
     $ + (PB(7)*BP(2,2)+PB(8)*BP(4,2)+PB(29)*BP(6,2)
     $  )*CSTL*F7B
     $ +(PB(13)*BP(3,2)+PB(146)*BP(5,2))
     $    *CD14*CSTL*F75B*SWC(5)
      F7C=1.
      F75C=1.
      WC(1,7)=-(PC(4)*BP(3,2)+PC(5)*BP(5,2)+PC(28)*BP(7,2)
     $   +PC(141)*BP(9,2)+PC(143)*BP(11,2)
     $  )*SSTL*F7C
     $ -(PC(12)*BP(2,2)+PC(145)*BP(4,2))
     $    *CD14*SSTL
     $   *F75C*SWC(5)
     $ +(PC(7)*BP(3,2)+PC(8)*BP(5,2)+PC(29)*BP(7,2)
     $ +PC(142)*BP(9,2)+PC(144)*BP(11,2)
     $  )*CSTL*F7C
     $ +(PC(13)*BP(2,2)+PC(146)*BP(4,2))
     $     *CD14*CSTL
     $   *F75C*SWC(5)
      WC(2,7)=-(PC(7)*BT(3,2)+PC(8)*BT(5,2)+PC(29)*BT(7,2)
     $ +PC(142)*BT(9,2)+PC(144)*BT(11,2)
     $  )*SSTL*F7C
     $ -(PC(13)*BT(2,2)+PC(146)*BT(4,2))
     $    *CD14*SSTL
     $   *F75C*SWC(5)
     $ -(PC(4)*BT(3,2)+PC(5)*BT(5,2)+PC(28)*BT(7,2)
     $ +PC(141)*BT(9,2)+PC(143)*BT(11,2)
     $  )*CSTL*F7C
     $ -(PC(12)*BT(2,2)+PC(145)*BT(4,2))
     $    *CD14*CSTL
     $   *F75C*SWC(5)
  200 CONTINUE
C       SEMIDIURNAL
      IF(SW(8).EQ.0) GOTO 210
      F8B=1.+PB(90)*DFC*SWC(1)
      WB(1,8)=(PB(9)*BT(3,3)+PB(43)*BT(5,3)
     $   +PB(111)*BT(7,3)
     $   +(PB(34)*BT(4,3)+PB(148)*BT(6,3))*CD14*SWC(5)
     $  )*S2STL*F8B
     $ +(PB(6)*BT(3,3)+PB(42)*BT(5,3)
     $   +PB(110)*BT(7,3)
     $   +(PB(24)*BT(4,3)+PB(147)*BT(6,3))*CD14*SWC(5)
     $  )*C2STL*F8B
      WB(2,8)=-(PB(6)*BP(3,3)+PB(42)*BP(5,3)
     $   +PB(110)*BP(7,3)
     $   +(PB(24)*BP(4,3)+PB(147)*BP(6,3))*CD14*SWC(5)
     $  )*S2STL*F8B
     $   + (PB(9)*BP(3,3)+PB(43)*BP(5,3)
     $   +PB(111)*BP(7,3)
     $   +(PB(34)*BP(4,3)+PB(148)*BP(6,3))*CD14*SWC(5)
     $  )*C2STL*F8B
      F8C=1.+PC(90)*DFC*SWC(1)
      WC(1,8)=-(PC(6)*BP(4,3)+PC(42)*BP(6,3)
     $   +PC(110)*BP(8,3)
     $   +(PC(24)*BP(3,3)+PC(147)*BP(5,3))*CD14*SWC(5)
     $  )*S2STL*F8C
     $ +(PC(9)*BP(4,3)+PC(43)*BP(6,3)
     $   +PC(111)*BP(8,3)
     $   +(PC(34)*BP(3,3)+PC(148)*BP(5,3))*CD14*SWC(5)
     $  )*C2STL*F8C
      WC(2,8)=-(PC(9)*BT(4,3)+PC(43)*BT(6,3)
     $   +PC(111)*BT(8,3)
     $   +(PC(34)*BT(3,3)+PC(148)*BT(5,3))*CD14*SWC(5)
     $  )*S2STL*F8C
     $ - (PC(6)*BT(4,3)+PC(42)*BT(6,3)
     $   +PC(110)*BT(8,3)
     $   +(PC(24)*BT(3,3)+PC(147)*BT(5,3))*CD14*SWC(5)
     $  )*C2STL*F8C
  210 CONTINUE
C        TERDIURNAL
C        MAGNETIC ACTIVITY
      IF(SW(9).EQ.0) GOTO 40
      IF(SW9.EQ.-1.) GOTO 30
C           daily AP
      WB(1,9)=(PB(46)*BT(3,1)+PB(35)*BT(5,1))*APDF
     $    +(PB(122)*BT(2,2)+PB(123)*BT(4,2)+PB(124)*BT(6,2)
     $       )*COS(HR*(STL-PB(125)))*APDF*SWC(7)
      WB(2,9)=
     $   (PB(122)*BP(2,2)+PB(123)*BP(4,2)+PB(124)*BP(6,2)
     $     )*COS(HR*(STL-PB(125)+6.))*APDF*SWC(7)
      WC(1,9)=
     $   (PC(122)*BP(3,2)+PC(123)*BP(5,2)+PC(124)*BP(7,2)
     $       )*COS(HR*(STL-PC(125)))*APDFC*SWC(7)
      WC(2,9)=-(PC(46)*BT(2,1)+PC(35)*BT(4,1))*APDFC
     $  +(PC(122)*BT(3,2)+PC(123)*BT(5,2)+PC(124)*BT(7,2)
     $       )*COS(HR*(STL-PC(125)+6.))*APDFC*SWC(7)
      GO TO 40
   30 CONTINUE
      IF(PB(25).LT.1.E-4) PB(25)=1.E-4
      WB(1,9)=(PB(97)*BT(3,1)+PB(55)*BT(5,1))*APT
     $    +(PB(129)*BT(2,2)+PB(130)*BT(4,2)+PB(131)*BT(6,2)
     $       )*COS(HR*(STL-PB(132)))*APT*SWC(7)
      WB(2,9)=
     $   (PB(129)*BP(2,2)+PB(130)*BP(4,2)+PB(131)*BP(6,2)
     $     )*COS(HR*(STL-PB(132)+6.))*APT*SWC(7)
      WC(1,9)=
     $   (PC(129)*BP(3,2)+PC(130)*BP(5,2)+PC(131)*BP(7,2)
     $       )*COS(HR*(STL-PC(132)))*APT*SWC(7)
      WC(2,9)=-(PC(97)*BT(2,1)+PC(55)*BT(4,1))*APT
     $  +(PC(129)*BT(3,2)+PC(130)*BT(5,2)+PC(131)*BT(7,2)
     $       )*COS(HR*(STL-PC(132)+6.))*APT*SWC(7)
  40  CONTINUE
      IF(SW(10).EQ.0) GOTO 49
C        LONGITUDINAL
C       UT & MIXED UT/LONG
C       MIXED LONG,UT,AP
      IF(SW9.EQ.-1.) GO TO 45
      GOTO 48
   45 CONTINUE
   48 CONTINUE
   49 CONTINUE
      WBT(1)=0
      WBT(2)=0
      WCT(1)=0
      WCT(2)=0
C       SUM WINDS AND CHANGE MERIDIONAL SIGN TO + NORTH
      DO 50 K=1,NSW
        WBT(1)=WBT(1)-ABS(SW(K))*WB(1,K)
        WCT(1)=WCT(1)-ABS(SW(K))*WC(1,K)
        WBT(2)=WBT(2)+ABS(SW(K))*WB(2,K)
        WCT(2)=WCT(2)+ABS(SW(K))*WC(2,K)
   50 CONTINUE
      WW(1)=WBT(1)*SW(24)+WCT(1)*SW(25)
      WW(2)=WBT(2)*SW(24)+WCT(2)*SW(25)
      RETURN
      END
C-----------------------------------------------------------------------
      SUBROUTINE TSELEC(SV)
C        SET SWITCHES
C        SW FOR MAIN TERMS, SWC FOR CROSS TERMS
      DIMENSION SV(1),SAV(25),SVV(1)
      COMMON/CSW/SW(25),ISW,SWC(25)
      SAVE
      DO 100 I = 1,25
        SAV(I)=SV(I)
        SW(I)=AMOD(SV(I),2.)
        IF(ABS(SV(I)).EQ.1.OR.ABS(SV(I)).EQ.2.) THEN
          SWC(I)=1.
        ELSE
          SWC(I)=0.
        ENDIF
  100 CONTINUE
      ISW=64999
      RETURN
      ENTRY TRETRV(SVV)
      DO 200 I=1,25
        SVV(I)=SAV(I)
  200 CONTINUE
      END
C-----------------------------------------------------------------------
      SUBROUTINE VSPHER(THETA,L,M,BT,BP,LMAX)
C      CALCULATE VECTOR SPHERICAL HARMONIC B FIELD THETA AND PHI
C      FUNCTIONS BT,BP FOR GEOGRAPHICAL LATITUDE THETA THROUGH ORDER L,M
C      BT(L+1,M+1)= [(L-M+1) P(L+1,M) - (L+1) P(L,M) SIN(THETA)] /
C                [SQRT(L(L+1)) COS(THETA)]
C      BP(L+1,M+1)= M P(L,M) /[SQRT(L(L+1)) COS(THETA)]
C       RESULT FOR GIVEN L,M SAVED IN BT AND BP AT ONE HIGHER INDEX NUM
      DIMENSION BT(LMAX,1),BP(LMAX,1),PLG(20,20)
      SAVE
      DATA DGTR/1.74533E-2/
      IF(M.GT.L.OR.L.GT.LMAX-1) THEN
        WRITE(6,100) L,M,LMAX
  100   FORMAT('ILLEGAL INDICIES TO VSPHER',3I6)
        RETURN
      ENDIF
      BT(1,1)=0
      BP(1,1)=0
      IF(L.EQ.0.AND.M.EQ.0) RETURN
      CALL LEGPOL(THETA,L+1,M,PLG,20)
      C=SIN(THETA*DGTR)
      S=COS(THETA*DGTR)     
      IF(ABS(S).LT.1.E-5) THEN
        S=0
        IC=SIGN(1,IFIX(THETA))
      ENDIF
      DO 20 LL=1,L
        SQT=SQRT(FLOAT(LL)*(FLOAT(LL)+1))
        LMX=MIN(LL,M)
        DO 15 MM=0,LMX
          IF(S.EQ.0) THEN
            IF(MM.NE.1) THEN
              BT(LL+1,MM+1)=0
              BP(LL+1,MM+1)=0
            ELSE
              BT(LL+1,MM+1)=(LL*(LL+1)*(LL+2)*.5*(IC)**(LL+2)
     $           -(LL+1)*C*LL*(LL+1)*.5*(IC)**(LL+1))/SQT
              BP(LL+1,MM+1)=MM*LL*(LL+1)*.5*(IC)**(LL+1)/SQT
            ENDIF
          ELSE
            BT(LL+1,MM+1)=((LL-MM+1)*PLG(LL+2,MM+1)
     $      -(LL+1)*C*PLG(LL+1,MM+1))/(S*SQT)
            BP(LL+1,MM+1)=MM*PLG(LL+1,MM+1)/(S*SQT)
          ENDIF
   15   CONTINUE
   20 CONTINUE
      END
C-----------------------------------------------------------------------
      SUBROUTINE LEGPOL(GLAT,L,M,PLG,LMAX)
C      CALCULATE LEGENDRE POLYNOMIALS PLG(L+1,M+1) FOR GEOGRAPHICAL
C      LATITUDE GLAT THROUGH ORDER L,M
      DIMENSION PLG(LMAX,1)
      SAVE
      DATA DGTR/1.74533E-2/
      IF(M.GT.L.OR.L.GT.LMAX-1) THEN
        WRITE(6,99) L,M,LMAX
   99 FORMAT(1X,'ILLEGAL INDICIES TO LEGPOL',3I5)
        RETURN
      ENDIF
      PLG(1,1)=1.
      IF(L.EQ.0.AND.M.EQ.0) RETURN
      C=SIN(GLAT*DGTR)
      S=COS(GLAT*DGTR)     
C      CALCULATE L=M CASE AND L=M+1
      DO 10 MM=0,M
        IF(MM.GT.0) PLG(MM+1,MM+1)=PLG(MM,MM)*(2.*MM-1.)*S
        IF(L.GT.MM) PLG(MM+2,MM+1)=PLG(MM+1,MM+1)*(2.*MM+1)*C
   10 CONTINUE
      IF(L.EQ.1) RETURN
      MMX=MIN(M,L-2)
      DO 30 MM=0,MMX
        DO 20 LL=MM+2,L
          PLG(LL+1,MM+1)=((2.*LL-1.)*C*PLG(LL,MM+1)-
     $     (LL+MM-1.)*PLG(LL-1,MM+1))/(LL-MM)
   20   CONTINUE
   30 CONTINUE
      RETURN
      END
C-----------------------------------------------------------------------
      SUBROUTINE SPLINE(X,Y,N,YP1,YPN,Y2)
C        CALCULATE 2ND DERIVATIVES OF CUBIC SPLINE INTERP FUNCTION
C        ADAPTED FROM NUMERICAL RECIPES BY PRESS ET AL
C        X,Y: ARRAYS OF TABULATED FUNCTION IN ASCENDING ORDER BY X
C        N: SIZE OF ARRAYS X,Y
C        YP1,YPN: SPECIFIED DERIVATIVES AT X(1) AND X(N); VALUES
C                 >= 1E30 SIGNAL SIGNAL SECOND DERIVATIVE ZERO
C        Y2: OUTPUT ARRAY OF SECOND DERIVATIVES
      PARAMETER (NMAX=100)
      DIMENSION X(N),Y(N),Y2(N),U(NMAX)
      SAVE
      IF(YP1.GT..99E30) THEN
        Y2(1)=0
        U(1)=0
      ELSE
        Y2(1)=-.5
        U(1)=(3./(X(2)-X(1)))*((Y(2)-Y(1))/(X(2)-X(1))-YP1)
      ENDIF
      DO 11 I=2,N-1
        SIG=(X(I)-X(I-1))/(X(I+1)-X(I-1))
        P=SIG*Y2(I-1)+2.
        Y2(I)=(SIG-1.)/P
        U(I)=(6.*((Y(I+1)-Y(I))/(X(I+1)-X(I))-(Y(I)-Y(I-1))
     $    /(X(I)-X(I-1)))/(X(I+1)-X(I-1))-SIG*U(I-1))/P
   11 CONTINUE
      IF(YPN.GT..99E30) THEN
        QN=0
        UN=0
      ELSE
        QN=.5
        UN=(3./(X(N)-X(N-1)))*(YPN-(Y(N)-Y(N-1))/(X(N)-X(N-1)))
      ENDIF
      Y2(N)=(UN-QN*U(N-1))/(QN*Y2(N-1)+1.)
      DO 12 K=N-1,1,-1
        Y2(K)=Y2(K)*Y2(K+1)+U(K)
   12 CONTINUE
      RETURN
      END
C-----------------------------------------------------------------------
      SUBROUTINE SPLINT(XA,YA,Y2A,N,X,Y)
C        CALCULATE CUBIC SPLINE INTERP VALUE
C        XA,YA: ARRAYS OF TABULATED FUNCTION IN ASCENDING ORDER BY X
C        Y2A: ARRAY OF SECOND DERIVATIVES
C        N: SIZE OF ARRAYS XA,YA,Y2A
C        X: ABSCISSA FOR INTERPOLATION
C        Y: OUTPUT VALUE
      DIMENSION XA(N),YA(N),Y2A(N)
      SAVE
      KLO=1
      KHI=N
    1 CONTINUE
      IF(KHI-KLO.GT.1) THEN
        K=(KHI+KLO)/2
        IF(XA(K).GT.X) THEN
          KHI=K
        ELSE
          KLO=K
        ENDIF
        GOTO 1
      ENDIF
      H=XA(KHI)-XA(KLO)
      IF(H.EQ.0) WRITE(6,*) 'BAD XA INPUT TO SPLINT'
      A=(XA(KHI)-X)/H
      B=(X-XA(KLO))/H
      Y=A*YA(KLO)+B*YA(KHI)+
     $  ((A*A*A-A)*Y2A(KLO)+(B*B*B-B)*Y2A(KHI))*H*H/6.
      RETURN
      END
C-----------------------------------------------------------------------
      BLOCK DATA GWS4BK
C          HWM90     4-MAY-90   
      COMMON/PARMW4/PWB1(50),PWB2(50),PWB3(50),PWB4(50),
     $PWC1(50),PWC2(50),PWC3(50),PWC4(50),
     $PWBL1(50),PWBL2(50),PWBL3(50),PWCL1(50),PWCL2(50),PWCL3(50),
     $PWBLD1(50),PWBLD2(50),PWBLD3(50),PWCLD1(50),PWCLD2(50),PWCLD3(50),
     $PWB01(50),PWB02(50),PWB03(50),PWC01(50),PWC02(50),PWC03(50),
     $PWB0D1(50),PWB0D2(50),PWB0D3(50),PWC0D1(50),PWC0D2(50),PWC0D3(50),
     $PWB0M1(50),PWB0M2(50),PWB0M3(50),PWC0M1(50),PWC0M2(50),PWC0M3(50),
     $PWBM1(50),PWBM2(50),PWBM3(50),PWCM1(50),PWCM2(50),PWCM3(50),
     $PWBMD1(50),PWBMD2(50),PWBMD3(50),PWCMD1(50),PWCMD2(50),PWCMD3(50)
      COMMON/DATW4/ISDATE(3),ISTIME(2),NAME(2)
      DATA ISDATE/' 4-M','AY-9','0   '/,ISTIME/'18:3','9:52'/
      DATA NAME/'HWM9','0   '/
C         PWB
      DATA PWB1/
     *  0.00000E+00,-1.31640E+01,-1.52352E+01, 1.00718E+02, 3.94962E+00,
     *  2.19452E-01, 8.03296E+01,-1.02032E+00,-2.02149E-01, 5.67263E+01,
     *  0.00000E+00,-6.05459E+00, 6.68106E+00,-8.49486E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 8.39399E+01, 0.00000E+00, 9.96285E-02,
     *  0.00000E+00,-2.66243E-02, 0.00000E+00,-1.32373E+00, 1.39396E-02,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 3.36523E+01,-7.42795E-01,-3.89352E+00,-7.81354E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 3.76631E+00,-1.22024E+00,
     * -5.47580E-01, 1.09146E+00, 9.06245E-01, 2.21119E-02, 0.00000E+00,
     *  7.73919E-02, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWB2/
     * -3.82415E-01, 0.00000E+00, 1.76202E-01, 0.00000E+00,-6.77651E-01,
     *  1.10357E+00, 2.25732E+00, 0.00000E+00, 1.54237E+04, 0.00000E+00,
     *  1.27411E-01,-2.84314E-03, 4.62562E-01,-5.34596E+01,-7.23808E+00,
     *  0.00000E+00, 0.00000E+00, 4.52770E-01,-8.50922E+00,-2.85389E-01,
     *  2.12000E+01, 6.80171E+02, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     * -2.72552E+04, 0.00000E+00, 0.00000E+00, 0.00000E+00, 2.64109E+03,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-1.47320E+00,-2.98179E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 1.05412E-02,
     *  4.93452E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 7.98332E-02,-5.30954E+01, 2.10211E-02, 0.00000E+00/
      DATA PWB3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,-2.79843E-01,
     *  1.81152E-01, 0.00000E+00, 0.00000E+00,-6.24673E-02,-5.37589E-02,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-8.48854E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 4.75654E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 6.85704E+00, 0.00000E+00,-8.94418E-02, 3.70413E+00,
     *  0.00000E+00, 1.47178E+01, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,-4.84645E+00,
     *  4.24178E-01, 0.00000E+00, 0.00000E+00, 1.86494E-01,-9.56931E-02/
      DATA PWB4/
     *  2.08426E+00, 1.53714E+00,-2.87496E-01, 4.06380E-01,-3.59788E-01,
     * -1.87814E-01, 0.00000E+00, 0.00000E+00, 2.01362E-01,-1.21604E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 7.86304E+00,
     *  2.51878E+00, 2.91455E+00, 4.32308E+00, 6.77054E-02,-2.39125E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  1.57976E+00,-5.44598E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     * -5.30593E-01,-5.02237E-01,-2.05258E-01, 2.62263E-01,-2.50195E-01,
     *  4.28151E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C         PWC
      DATA PWC1/
     *  0.00000E+00, 1.31026E+01,-4.93171E+01, 2.51045E+01,-1.30531E+01,
     *  6.56421E-01, 2.75633E+01, 4.36433E+00, 1.04638E+00, 5.77365E+01,
     *  0.00000E+00,-6.27766E+00, 2.33010E+00,-1.41351E+01, 2.49653E-01,
     *  0.00000E+00, 0.00000E+00, 8.00000E+01, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 1.03817E-02,-1.70950E+01,-1.92295E+00, 4.01565E-02,
     *  8.29674E-02,-1.17490E+01,-7.14788E-01, 6.72649E+00, 0.00000E+00,
     *  0.00000E+00,-1.57793E+02,-1.70815E+00,-7.92416E+00,-1.67372E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 1.87973E-01,
     * -1.61602E-01,-1.13832E-01,-7.22447E-01, 4.15805E-02, 1.05645E-01,
     * -3.01967E+00,-1.72798E-01,-5.15055E-03,-1.23477E-02, 3.60805E-03/
      DATA PWC2/
     * -1.36730E+00, 0.00000E+00, 1.24390E-02, 0.00000E+00,-1.36577E+00,
     *  3.18101E-02, 0.00000E+00, 0.00000E+00, 0.00000E+00,-1.39334E+01,
     *  1.42088E-02, 0.00000E+00, 0.00000E+00, 0.00000E+00,-4.72219E+00,
     * -7.47970E+00,-4.96528E+00, 0.00000E+00, 1.24712E+00,-2.56833E+01,
     * -4.26630E+01, 3.92431E+04,-2.57155E+00,-4.35589E-02, 0.00000E+00,
     *  0.00000E+00, 2.02425E+00,-1.48131E+00,-7.72242E-01, 2.99008E+04,
     *  4.50148E-03, 5.29718E-03,-1.26697E-02, 3.20909E-02, 0.00000E+00,
     *  0.00000E+00, 7.01739E+00, 3.11204E+00, 0.00000E+00, 0.00000E+00,
     * -2.13088E+00, 1.32789E+01, 5.07958E+00, 7.26537E-02, 2.87495E-01,
     *  9.97311E-03,-2.56440E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWC3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-9.90073E-03,-3.27333E-02,
     * -4.30379E+01,-2.87643E+01,-5.91793E+00,-1.50460E+02, 0.00000E+00,
     *  0.00000E+00, 6.55038E-03, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 6.18051E-03, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  1.40484E+00, 5.54554E+00, 0.00000E+00, 0.00000E+00, 7.93810E+00,
     *  1.57192E+00, 1.03971E+00, 9.88279E-01,-4.37662E-02,-2.15763E-02/
      DATA PWC4/
     * -2.31583E+00, 4.32633E+00,-1.12716E+00, 3.38459E-01, 4.66956E-01,
     *  7.18403E-01, 5.80836E-02, 4.12653E-01, 1.04111E-01,-8.30672E-02,
     * -5.55541E+00,-4.97473E+00,-2.03007E+01, 0.00000E+00,-6.06235E-01,
     * -1.73121E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 9.29850E-02,-6.38131E-02,
     *  3.93037E-02, 5.21942E-02, 2.26578E-02, 4.13157E-02, 0.00000E+00,
     *  6.28524E+00, 4.43721E+00,-4.31270E+00, 2.32787E+00, 2.55591E-01,
     *  1.60098E+00,-1.20649E+00, 3.05042E+00,-1.88944E+00, 5.35561E+00,
     *  2.02391E-01, 4.62950E-02, 3.39155E-01, 7.94007E-02, 6.30345E-01,
     *  1.93554E-01, 3.93238E-01, 1.76254E-01,-2.51359E-01,-7.06879E-01/
C       PWBL
      DATA PWBL1/
     *  6.22831E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  5.90566E+00, 0.00000E+00, 0.00000E+00,-3.20571E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-8.30368E-01, 1.00000E-04,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 2.40657E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00,-4.80790E+00,-1.62744E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBL2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBL3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 2.10531E-01,
     * -8.94829E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C         PWCL
      DATA PWCL1/
     *  5.45009E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     * -3.60304E+00, 0.00000E+00, 0.00000E+00,-5.04071E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 5.62113E-01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 1.14657E+01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 4.65483E-01, 1.73636E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCL2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCL3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,-8.30769E-01,
     *  7.73649E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C         PWBLD
      DATA PWBLD1/
     *  6.09940E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 1.00000E-04,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBLD2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBLD3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C        PWCLD
      DATA PWCLD1/
     *  5.46739E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCLD2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCLD3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C        PWB0
      DATA PWB01/
     *  4.99007E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  2.59994E+00, 0.00000E+00, 0.00000E+00,-1.78418E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-5.24986E+00, 1.00000E-04,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 2.77918E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWB02/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWB03/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 5.68996E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C         PWC0
      DATA PWC01/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     * -7.26156E+00, 0.00000E+00, 0.00000E+00,-4.12416E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-2.88934E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 3.65720E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWC02/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWC03/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 2.01835E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C        PWB0D
      DATA PWB0D1/
     *  0.00000E+00,-1.37217E+01, 0.00000E+00, 2.38712E-01,-3.92230E+00,
     *  6.11035E+00,-1.57794E+00,-5.87709E-01, 1.21178E+01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 5.23202E+01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00,-2.22836E+03, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-3.94006E+00, 1.00000E-04,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 3.99844E-01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00,-1.38936E+00, 2.22534E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWB0D2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWB0D3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 4.35518E-01, 8.40051E-01, 0.00000E+00,-8.88181E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 6.81729E-01, 9.67536E-01,
     *  0.00000E+00,-9.67836E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C          PWC0D
      DATA PWC0D1/
     *  0.00000E+00,-2.75655E+01,-6.61134E+00, 4.85118E+00, 8.15375E-01,
     * -2.62856E+00, 2.99508E-02,-2.00532E-01,-9.35618E+00, 1.17196E+01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00,-2.43848E+00, 1.90065E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00,-3.37525E-01, 1.76471E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWC0D2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWC0D3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00,-9.23682E-01,-8.84150E-02, 0.00000E+00,-9.88578E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-1.00747E+00,-1.07468E-02,
     *  0.00000E+00,-3.66376E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C           PWB0M
      DATA PWB0M1/
     *  0.00000E+00, 1.02709E+01, 0.00000E+00,-1.42016E+00,-4.90438E+00,
     * -9.11544E+00,-3.80570E+00,-2.09013E+00, 1.32939E+01,-1.28062E+01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 1.23024E+01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 3.92126E+02, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 1.00000E-04,
     *  0.00000E+00, 0.00000E+00,-5.56532E+00,-1.27046E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00,-3.03553E+00,-9.09832E-01, 0.00000E+00, 0.00000E+00,
     *  8.89965E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWB0M2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 9.19210E-01, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWB0M3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00,-2.46693E-01, 7.44650E-02, 3.84661E-01, 9.44052E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-2.25083E-01, 1.54206E-01,
     *  4.41303E-01, 8.74742E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C           PWC0M
      DATA PWC0M1/
     *  0.00000E+00, 3.61143E+00,-8.24679E+00, 1.70751E+00, 1.16676E+00,
     *  6.24821E+00,-5.68968E-01, 8.53046E-01,-6.94168E+00, 1.04152E+01,
     * -3.70861E+01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     * -1.23336E+01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 5.33958E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00,-6.43682E-01,-1.00000E+00,-1.00000E-01,
     *  0.00000E+00,-1.00000E+00, 0.00000E+00,-5.47300E-01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00,-8.58764E-01, 4.72310E-01, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWC0M2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWC0M3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 3.37325E-01,-3.57698E-02,-6.97393E-01, 1.35387E+01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 2.78162E-01,-2.33383E-01,
     * -7.12994E-01, 1.29234E+01, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C         PWBM
      DATA PWBM1/
     *  0.00000E+00, 7.82338E+00, 5.89368E+00, 3.44454E+00,-2.78073E+00,
     *  3.97437E-01,-7.75963E-01,-3.73828E+00,-1.48133E+01, 7.83660E-02,
     * -4.56433E+00, 0.00000E+00, 0.00000E+00,-2.55204E+01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 1.41557E+01, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-6.55137E+00, 1.00000E-04,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00,-1.30203E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBM2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBM3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,-2.36181E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C         PWCM
      DATA PWCM1/
     *  0.00000E+00, 6.23932E+00, 7.49123E+00, 2.50564E+00, 0.00000E+00,
     *  5.35106E-01, 5.61033E+00, 0.00000E+00,-2.39646E+00,-2.15318E+01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  1.47531E+01, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCM2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCM3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,-1.91762E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C          PWBMD
      DATA PWBMD1/
     *  0.00000E+00,-3.02522E+00, 0.00000E+00, 2.21108E+00, 0.00000E+00,
     * -6.12709E+00, 3.44383E+00, 0.00000E+00, 1.15625E+00,-1.73642E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 7.13874E+01, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 1.00000E-04,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 1.30628E+00,-3.76543E-01, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBMD2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWBMD3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
C          PWCMD
      DATA PWCMD1/
     *  0.00000E+00,-4.55542E+00, 6.95821E+00,-2.84665E+00, 0.00000E+00,
     *  4.99881E-01, 4.71030E+00, 0.00000E+00, 1.27509E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 1.04402E-01,-7.43208E-01, 4.15805E-02, 1.05645E-01,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCMD2/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      DATA PWCMD3/
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00,
     *  0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00, 0.00000E+00/
      END
*************************************************************************

C      TEST DRIVER FOR GWS4 (HWM90 HORIZONTAL WIND MODEL)
      DIMENSION W(2,15)
      DIMENSION IDAY(15),UT(15),ALT(15),XLAT(15),XLONG(15),XLST(15),
     $ F107A(15),F107(15),AP(15)    
      COMMON/HWMC/WBT(2),WCT(2)
      DATA IDAY/172,81,8*172,3*81.,182.,182./
      DATA UT/29000.,29000.,75000.,12*29000./
      DATA ALT/400.,400.,400.,200.,6*400.,5*100./
      DATA XLAT/4*60.,0.,5*60.,4*45.,0/
      DATA XLONG/5*-70.,0.,4*-70.,5*0/
      DATA XLST/6*16.,4.,3*16.,0.,6.,9.,12.,0/
      DATA F107A/7*150.,70.,150.,150.,5*150./
      DATA F107/8*150.,180.,150.,5*150./
      DATA AP/9*4.,40.,4.,40.,3*4./
      DO 10 I=1,15
         CALL GWS4(IDAY(I),UT(I),ALT(I),XLAT(I),XLONG(I),XLST(I),
     $             F107A(I),F107(I),AP(I),W(1,I))
         WRITE(6,100) W(1,I),WBT(1),WCT(1),W(2,I),WBT(2),WCT(2)
   10 CONTINUE
      WRITE(6,200) (IDAY(I),I=1,5)
      WRITE(6,201) (UT(I),I=1,5)
      WRITE(6,202) (ALT(I),I=1,5)
      WRITE(6,203) (XLAT(I),I=1,5)
      WRITE(6,204) (XLONG(I),I=1,5)
      WRITE(6,205) (XLST(I),I=1,5)
      WRITE(6,206) (F107A(I),I=1,5)
      WRITE(6,207) (F107(I),I=1,5)
      WRITE(6,210) (AP(I),I=1,5)
      WRITE(6,208) (W(1,I),I=1,5)
      WRITE(6,209) (W(2,I),I=1,5)
      WRITE(6,200) (IDAY(I),I=6,10)
      WRITE(6,201) (UT(I),I=6,10)
      WRITE(6,202) (ALT(I),I=6,10)
      WRITE(6,203) (XLAT(I),I=6,10)
      WRITE(6,204) (XLONG(I),I=6,10)
      WRITE(6,205) (XLST(I),I=6,10)
      WRITE(6,206) (F107A(I),I=6,10)
      WRITE(6,207) (F107(I),I=6,10)
      WRITE(6,210) (AP(I),I=6,10)
      WRITE(6,208) (W(1,I),I=6,10)
      WRITE(6,209) (W(2,I),I=6,10)
      WRITE(6,200) (IDAY(I),I=11,15)
      WRITE(6,201) (UT(I),I=11,15)
      WRITE(6,202) (ALT(I),I=11,15)
      WRITE(6,203) (XLAT(I),I=11,15)
      WRITE(6,204) (XLONG(I),I=11,15)
      WRITE(6,205) (XLST(I),I=11,15)
      WRITE(6,206) (F107A(I),I=11,15)
      WRITE(6,207) (F107(I),I=11,15)
      WRITE(6,210) (AP(I),I=11,15)
      WRITE(6,208) (W(1,I),I=11,15)
      WRITE(6,209) (W(2,I),I=11,15)
  100 FORMAT(1X,6F10.2)
  200 FORMAT(//' DAY  ',5I12)
  201 FORMAT(' UT   ',5F12.0)
  202 FORMAT(' ALT  ',5F12.0)
  203 FORMAT(' LAT  ',5F12.0)
  204 FORMAT(' LONG ',5F12.0)
  205 FORMAT(' LST  ',5F12.0)
  206 FORMAT(' F107A',5F12.0)
  207 FORMAT(' F107 ',5F12.0)
  210 FORMAT(' AP   ',5F12.0)
  208 FORMAT(/'   U  ',5F12.2)
  209 FORMAT('   V  ',5F12.2)
      STOP
      END
