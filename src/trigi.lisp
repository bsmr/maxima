;;; -*-  Mode: Lisp; Package: Maxima; Syntax: Common-Lisp; Base: 10 -*- ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     The data in this file contains enhancments.                    ;;;;;
;;;                                                                    ;;;;;
;;;  Copyright (c) 1984,1987 by William Schelter,University of Texas   ;;;;;
;;;     All rights reserved                                            ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     (c) Copyright 1982 Massachusetts Institute of Technology         ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "MAXIMA")
(macsyma-module trigi)

(LOAD-MACSYMA-MACROS MRGMAC)

(DECLARE-TOP(GENPREFIX TRI)
	 (SPECIAL VARLIST ERRORSW $DEMOIVRE)
	 (FLONUM (TAN) (COT) (SEC) (CSC)
		 (ATAN2) (ATAN1) (ACOT)
		 (SINH) (COSH) (TANH) (COTH) (CSCH) (SECH)
		 (ASINH) (ACSCH)
		 (T//$ FLONUM FLONUM NOTYPE))
	 (*EXPR $BFLOAT TEVAL SIGNUM1 ZEROP1 ISLINEAR EXPAND1
		TIMESK ADDK MAXIMA-INTEGERP EVOD LOGARC
		MEVENP EQTEST HALFANGLE COEFF))

(DEFMVAR $%PIARGS T)
(DEFMVAR $%IARGS T)
(DEFMVAR $TRIGINVERSES '$ALL)
(DEFMVAR $TRIGEXPAND NIL)
(DEFMVAR $TRIGEXPANDPLUS T)
(DEFMVAR $TRIGEXPANDTIMES T)
(DEFMVAR $TRIGSIGN T)
(DEFMVAR $EXPONENTIALIZE NIL)
(DEFMVAR $LOGARC NIL)
(DEFMVAR $HALFANGLES NIL)

(DEFMVAR 1//2 '((RAT SIMP) 1 2))
(DEFMVAR -1//2 '((RAT SIMP) -1 2))
(DEFMVAR %PI//4 '((MTIMES SIMP) ((RAT SIMP) 1 4.) $%PI))
(DEFMVAR %PI//2 '((MTIMES SIMP) ((RAT SIMP) 1 2) $%PI))
(DEFMVAR SQRT2//2 '((MTIMES SIMP) ((RAT SIMP) 1 2)
				  ((MEXPT SIMP) 2 ((RAT SIMP) 1 2))))
(DEFMVAR -SQRT2//2 '((MTIMES SIMP) ((RAT SIMP) -1 2)
				   ((MEXPT SIMP) 2 ((RAT SIMP) 1 2))))
(DEFMVAR SQRT3//2 '((MTIMES SIMP) ((RAT SIMP) 1 2)
				  ((MEXPT SIMP) 3 ((RAT SIMP) 1 2))))
(DEFMVAR -SQRT3//2 '((MTIMES SIMP) ((RAT SIMP) -1 2)
				   ((MEXPT SIMP) 3 ((RAT SIMP) 1 2))))

;;; Arithmetic utilities.

(DEFMFUN SQRT1-X^2 (X) (POWER (SUB 1 (POWER X 2)) 1//2))

(DEFMFUN SQRT1+X^2 (X) (POWER (ADD 1 (POWER X 2)) 1//2))

(DEFMFUN SQRTX^2-1 (X) (POWER (ADD (POWER X 2) -1) 1//2))

(DEFMFUN SQ-SUMSQ (X Y) (POWER (ADD (POWER X 2) (POWER Y 2)) 1//2))

(DEFMFUN TRIGP (FUNC) (MEMQ FUNC '(%SIN %COS %TAN %CSC %SEC %COT
				   %SINH %COSH %TANH %CSCH %SECH %COTH)))

(DEFMFUN ARCP (FUNC) (MEMQ FUNC '(%ASIN %ACOS %ATAN %ACSC %ASEC %ACOT
				  %ASINH %ACOSH %ATANH %ACSCH %ASECH %ACOTH)))

(DEFPROP %SIN SIMP-%SIN OPERATORS)
(DEFPROP %COS SIMP-%COS OPERATORS)
(DEFPROP %TAN SIMP-%TAN OPERATORS)
(DEFPROP %COT SIMP-%COT OPERATORS)
(DEFPROP %CSC SIMP-%CSC OPERATORS)
(DEFPROP %SEC SIMP-%SEC OPERATORS)
(DEFPROP %SINH SIMP-%SINH OPERATORS)
(DEFPROP %COSH SIMP-%COSH OPERATORS)
(DEFPROP %TANH SIMP-%TANH OPERATORS)
(DEFPROP %COTH SIMP-%COTH OPERATORS)
(DEFPROP %CSCH SIMP-%CSCH OPERATORS)
(DEFPROP %SECH SIMP-%SECH OPERATORS)
(DEFPROP %ASIN SIMP-%ASIN OPERATORS)
(DEFPROP %ACOS SIMP-%ACOS OPERATORS)
(DEFPROP %ATAN SIMP-%ATAN OPERATORS)
(DEFPROP %ACOT SIMP-%ACOT OPERATORS)
(DEFPROP %ACSC SIMP-%ACSC OPERATORS)
(DEFPROP %ASEC SIMP-%ASEC OPERATORS)
(DEFPROP %ASINH SIMP-%ASINH OPERATORS)
(DEFPROP %ACOSH SIMP-%ACOSH OPERATORS)
(DEFPROP %ATANH SIMP-%ATANH OPERATORS)
(DEFPROP %ACOTH SIMP-%ACOTH OPERATORS)
(DEFPROP %ACSCH SIMP-%ACSCH OPERATORS)
(DEFPROP %ASECH SIMP-%ASECH OPERATORS)

(DEFMFUN SIMP-%SIN (FORM Y Z) 
  (ONEARGCHECK FORM)
  (SETQ Y (SIMPCHECK (CADR FORM) Z))
  (COND ((FLOATP Y) (SIN Y))
	((AND $NUMER (INTEGERP Y))
	 (SIN (FLOAT Y 2.0d0 )))
	(($BFLOATP Y) ($BFLOAT FORM))
	((AND $%PIARGS (COND ((ZEROP1 Y) 0) ((LINEARP Y '$%PI) (%PIARGS-SIN\COS Y)))))
	((AND $%IARGS (MULTIPLEP Y '$%I)) (MUL '$%I (CONS-EXP '%SINH (COEFF Y '$%I 1))))
	((AND $TRIGINVERSES (NOT (ATOM Y))
	      (COND ((EQ '%ASIN (SETQ Z (CAAR Y))) (CADR Y))
		    ((EQ '%ACOS Z) (SQRT1-X^2 (CADR Y)))
		    ((EQ '%ATAN Z) (DIV (CADR Y) (SQRT1+X^2 (CADR Y))))
		    ((EQ '%ACOT Z) (DIV 1 (SQRT1+X^2 (CADR Y))))
		    ((EQ '%ASEC Z) (DIV (SQRTX^2-1 (CADR Y)) (CADR Y)))
		    ((EQ '%ACSC Z) (DIV 1 (CADR Y)))
		    ((EQ '$ATAN2 Z) (DIV (CADR Y) (SQ-SUMSQ (CADR Y) (CADDR Y)))))))
	((AND $TRIGEXPAND (TRIGEXPAND '%SIN Y)))
	($EXPONENTIALIZE (EXPONENTIALIZE '%SIN Y))
	((AND $HALFANGLES (HALFANGLE '%SIN Y)))
	((AND $TRIGSIGN (MMINUSP* Y)) (NEG (CONS-EXP '%SIN (NEG Y))))
	(T (EQTEST (LIST '(%SIN) Y) FORM))))

(DEFMFUN SIMP-%COS (FORM Y Z) 
  (ONEARGCHECK FORM)
  (SETQ Y (SIMPCHECK (CADR FORM) Z))
  (COND ((FLOATP Y) (COS Y))
	((AND $NUMER (INTEGERP Y))
	 (COS (FLOAT Y 2.0d0 )))
	(($BFLOATP Y) ($BFLOAT FORM))
	((AND $%PIARGS (COND ((ZEROP1 Y) 1) ((LINEARP Y '$%PI) (%PIARGS-SIN\COS (ADD %PI//2 Y))))))
	((AND $%IARGS (MULTIPLEP Y '$%I)) (CONS-EXP '%COSH (COEFF Y '$%I 1)))
	((AND $TRIGINVERSES (NOT (ATOM Y))
	      (COND ((EQ '%ACOS (SETQ Z (CAAR Y))) (CADR Y))
		    ((EQ '%ASIN Z) (SQRT1-X^2 (CADR Y)))
		    ((EQ '%ATAN Z) (DIV 1 (SQRT1+X^2 (CADR Y))))
		    ((EQ '%ACOT Z) (DIV (CADR Y) (SQRT1+X^2 (CADR Y))))
		    ((EQ '%ASEC Z) (DIV 1 (CADR Y)))
		    ((EQ '%ACSC Z) (DIV (SQRTX^2-1 (CADR Y)) (CADR Y)))
		    ((EQ '$ATAN2 Z) (DIV (CADDR Y) (SQ-SUMSQ (CADR Y) (CADDR Y)))))))
	((AND $TRIGEXPAND (TRIGEXPAND '%COS Y)))
	($EXPONENTIALIZE (EXPONENTIALIZE '%COS Y))
	((AND $HALFANGLES (HALFANGLE '%COS Y)))
	((AND $TRIGSIGN (MMINUSP* Y)) (CONS-EXP '%COS (NEG Y)))
	(T (EQTEST (LIST '(%COS) Y) FORM))))

(DEFUN %PIARGS-SIN\COS (X)
  (LET ($FLOAT COEFF RATCOEFF zl-REM)
    (SETQ RATCOEFF (COEFFICIENT X '$%PI 1)
	  COEFF (LINEARIZE RATCOEFF) zl-REM (COEFFICIENT X '$%PI 0))
    (COND ((ZEROP1 zl-REM) (%PIARGS COEFF RATCOEFF))
	  ((NOT (MEVENP (CAR COEFF))) NIL)
	  ((EQUAL 0 (SETQ X (MMOD (CDR COEFF) 2))) (CONS-EXP '%SIN zl-REM))
	  ((EQUAL 1 X) (NEG (CONS-EXP '%SIN zl-REM)))
	  ((ALIKE1 1//2 X) (CONS-EXP '%COS zl-REM))
	  ((ALIKE1 '((RAT) 3 2) X) (NEG (CONS-EXP '%COS zl-REM))))))

(DEFMFUN SIMP-%TAN (FORM Y Z)
  (ONEARGCHECK FORM)
  (SETQ Y (SIMPCHECK (CADR FORM) Z))
  (COND ((FLOATP Y) (TAN Y))
	((AND $NUMER (INTEGERP Y))
	 (TAN (FLOAT Y 2.0d0 )))
	(($BFLOATP Y) ($BFLOAT FORM))
	((AND $%PIARGS (COND ((ZEROP1 Y) 0) ((LINEARP Y '$%PI) (%PIARGS-TAN\COT Y)))))
	((AND $%IARGS (MULTIPLEP Y '$%I)) (MUL '$%I (CONS-EXP '%TANH (COEFF Y '$%I 1))))
	((AND $TRIGINVERSES (NOT (ATOM Y))
	      (COND ((EQ '%ATAN (SETQ Z (CAAR Y))) (CADR Y))
		    ((EQ '%ASIN Z) (DIV (CADR Y) (SQRT1-X^2 (CADR Y))))
		    ((EQ '%ACOS Z) (DIV (SQRT1-X^2 (CADR Y)) (CADR Y)))
		    ((EQ '%ACOT Z) (DIV 1 (CADR Y)))
		    ((EQ '%ASEC Z) (SQRTX^2-1 (CADR Y)))
		    ((EQ '%ACSC Z) (DIV 1 (SQRTX^2-1 (CADR Y))))
		    ((EQ '$ATAN2 Z) (DIV (CADR Y) (CADDR Y))))))
	((AND $TRIGEXPAND (TRIGEXPAND '%TAN Y)))
	($EXPONENTIALIZE (EXPONENTIALIZE '%TAN Y))
	((AND $HALFANGLES (HALFANGLE '%TAN Y)))
	((AND $TRIGSIGN (MMINUSP* Y)) (NEG (CONS-EXP '%TAN (NEG Y))))
	(T (EQTEST (LIST '(%TAN) Y) FORM))))

(DEFMFUN SIMP-%COT (FORM Y Z)
  (ONEARGCHECK FORM)
  (SETQ Y (SIMPCHECK (CADR FORM) Z))
  
  (COND ((FLOATP Y) (COT Y))
	((AND $NUMER (INTEGERP Y))
	 (COT (FLOAT Y 2.0d0 )))
	(($BFLOATP Y) ($BFLOAT FORM))
	((AND $%PIARGS (COND ((ZEROP1 Y) (DBZ-ERR1 'COT))
			     ((AND (LINEARP Y '$%PI) (SETQ Z (%PIARGS-TAN\COT (ADD %PI//2 Y)))) (NEG Z)))))
	((AND $%IARGS (MULTIPLEP Y '$%I)) (MUL -1 '$%I (CONS-EXP '%COTH (COEFF Y '$%I 1))))
	((AND $TRIGINVERSES (NOT (ATOM Y))
	      (COND ((EQ '%ACOT (SETQ Z (CAAR Y))) (CADR Y))
		    ((EQ '%ASIN Z) (DIV (SQRT1-X^2 (CADR Y)) (CADR Y)))
		    ((EQ '%ACOS Z) (DIV (CADR Y) (SQRT1-X^2 (CADR Y))))
		    ((EQ '%ATAN Z) (DIV 1 (CADR Y)))
		    ((EQ '%ASEC Z) (DIV 1 (SQRTX^2-1 (CADR Y))))
		    ((EQ '%ACSC Z) (SQRTX^2-1 (CADR Y)))
		    ((EQ '$ATAN2 Z) (DIV (CADDR Y) (CADR Y))))))
	((AND $TRIGEXPAND (TRIGEXPAND '%COT Y)))
	($EXPONENTIALIZE (EXPONENTIALIZE '%COT Y))
	((AND $HALFANGLES (HALFANGLE '%COT Y)))
	((AND $TRIGSIGN (MMINUSP* Y)) (NEG (CONS-EXP '%COT (NEG Y))))
	(T (EQTEST (LIST '(%COT) Y) FORM))))

(DEFUN %PIARGS-TAN\COT (X)
    (PROG ($FLOAT COEFF zl-REM)
	(SETQ COEFF (LINEARIZE (COEFFICIENT X '$%PI 1)) zl-REM (COEFFICIENT X '$%PI 0))
	(RETURN (COND ((AND (ZEROP1 zl-REM)
			    (SETQ zl-REM (%PIARGS COEFF NIL))
			    (SETQ COEFF (%PIARGS (CONS (CAR COEFF) (RPLUS 1//2 (CDR COEFF)))
						 NIL)))
		       (DIV zl-REM COEFF))
		      ((NOT (MEVENP (CAR COEFF))) NIL)
		      ((INTEGERP (SETQ X (MMOD (CDR COEFF) 2))) (CONS-EXP '%TAN zl-REM))
		      ((OR (ALIKE1 1//2 X) (ALIKE1 '((RAT) 3 2) X)) (NEG (CONS-EXP '%COT zl-REM)))))))

(DEFMFUN SIMP-%CSC (FORM Y Z)
  (ONEARGCHECK FORM)
  (SETQ Y (SIMPCHECK (CADR FORM) Z))
  (COND ((FLOATP Y) (CSC Y))
	((AND $NUMER (INTEGERP Y))
	 (CSC (FLOAT Y 2.0d0 )))
	(($BFLOATP Y) ($BFLOAT FORM))
	((AND $%PIARGS (COND ((ZEROP1 Y) (DBZ-ERR1 'CSC))
			     ((LINEARP Y '$%PI) (%PIARGS-CSC\SEC Y)))))
	((AND $%IARGS (MULTIPLEP Y '$%I)) (MUL -1 '$%I (CONS-EXP '%CSCH (COEFF Y '$%I 1))))
	((AND $TRIGINVERSES (NOT (ATOM Y))
	      (COND ((EQ '%ACSC (SETQ Z (CAAR Y))) (CADR Y))
		    ((EQ '%ASIN Z) (DIV 1 (CADR Y)))
		    ((EQ '%ACOS Z) (DIV 1 (SQRT1-X^2 (CADR Y))))
		    ((EQ '%ATAN Z) (DIV (SQRT1+X^2 (CADR Y)) (CADR Y)))
		    ((EQ '%ACOT Z) (SQRT1+X^2 (CADR Y)))
		    ((EQ '%ASEC Z) (DIV (CADR Y) (SQRTX^2-1 (CADR Y))))
		    ((EQ '$ATAN2 Z) (DIV (SQ-SUMSQ (CADR Y) (CADDR Y)) (CADR Y))))))
	((AND $TRIGEXPAND (TRIGEXPAND '%CSC Y)))
	($EXPONENTIALIZE (EXPONENTIALIZE '%CSC Y))
	((AND $HALFANGLES (HALFANGLE '%CSC Y)))
	((AND $TRIGSIGN (MMINUSP* Y)) (NEG (CONS-EXP '%CSC (NEG Y))))
	
	(T (EQTEST (LIST '(%CSC) Y) FORM))))

(DEFMFUN SIMP-%SEC (FORM Y Z)
  (ONEARGCHECK FORM)
  (SETQ Y (SIMPCHECK (CADR FORM) Z))
  (COND ((FLOATP Y) (SEC Y))
	((AND $NUMER (INTEGERP Y))
	 (SEC (FLOAT Y 2.0d0 )))
	(($BFLOATP Y) ($BFLOAT FORM))
	((AND $%PIARGS (COND ((ZEROP1 Y) 1) ((LINEARP Y '$%PI) (%PIARGS-CSC\SEC (ADD %PI//2 Y))))))
	((AND $%IARGS (MULTIPLEP Y '$%I)) (CONS-EXP '%SECH (COEFF Y '$%I 1)))
	((AND $TRIGINVERSES (NOT (ATOM Y))
	      (COND ((EQ '%ASEC (SETQ Z (CAAR Y))) (CADR Y))
		    ((EQ '%ASIN Z) (DIV 1 (SQRT1-X^2 (CADR Y))))
		    ((EQ '%ACOS Z) (DIV 1 (CADR Y)))
		    ((EQ '%ATAN Z) (SQRT1+X^2 (CADR Y)))
		    ((EQ '%ACOT Z) (DIV (SQRT1+X^2 (CADR Y)) (CADR Y)))
		    ((EQ '%ACSC Z) (DIV (CADR Y) (SQRTX^2-1 (CADR Y))))
		    ((EQ '$ATAN2 Z) (DIV (SQ-SUMSQ (CADR Y) (CADDR Y)) (CADDR Y))))))
	((AND $TRIGEXPAND (TRIGEXPAND '%SEC Y)))
	($EXPONENTIALIZE (EXPONENTIALIZE '%SEC Y))
	((AND $HALFANGLES (HALFANGLE '%SEC Y)))
	((AND $TRIGSIGN (MMINUSP* Y)) (CONS-EXP '%SEC (NEG Y)))
	
	(T (EQTEST (LIST '(%SEC) Y) FORM))))

(DEFUN %PIARGS-CSC\SEC (X)
  (PROG ($FLOAT COEFF zl-REM)
	(SETQ COEFF (LINEARIZE (COEFFICIENT X '$%PI 1)) zl-REM (COEFFICIENT X '$%PI 0))
	(RETURN (COND ((AND (ZEROP1 zl-REM) (SETQ zl-REM (%PIARGS COEFF NIL))) (DIV 1 zl-REM))
		      ((NOT (MEVENP (CAR COEFF))) NIL)
		      ((EQUAL 0 (SETQ X (MMOD (CDR COEFF) 2))) (CONS-EXP '%CSC zl-REM))
		      ((EQUAL 1 X) (NEG (CONS-EXP '%CSC zl-REM)))
		      ((ALIKE1 1//2 X) (CONS-EXP '%SEC zl-REM))
		      ((ALIKE1 '((RAT) 3 2) X) (NEG (CONS-EXP '%SEC zl-REM)))))))

(DEFMFUN SIMP-%ATAN (FORM Y Z)
  (ONEARGCHECK FORM)
  (SETQ Y (SIMPCHECK (CADR FORM) Z))
  (COND ((FLOATP Y) (ATAN1 Y))
	((AND $NUMER (INTEGERP Y))
	 (ATAN1 (FLOAT Y 2.0d0 )))
	(($BFLOATP Y) ($BFLOAT FORM))
	((AND $%PIARGS
	      (COND ((ZEROP1 Y) 0) ((EQUAL 1 Y) %PI//4) ((EQUAL -1 Y) (NEG %PI//4)))))
	((AND $%IARGS (MULTIPLEP Y '$%I)) (MUL '$%I (CONS-EXP '%ATANH (COEFF Y '$%I 1))))
	((AND (EQ $TRIGINVERSES '$ALL) (NOT (ATOM Y))
	      (IF (EQ (CAAR Y) '%TAN) (CADR Y))))
	($LOGARC (LOGARC '%ATAN Y))
	((AND $TRIGSIGN (MMINUSP* Y)) (NEG (CONS-EXP '%ATAN (NEG Y))))
	(T (EQTEST (LIST '(%ATAN) Y) FORM))))

(DEFUN %PIARGS (X RATCOEFF)
  (COND ((AND (INTEGERP (CAR X)) (INTEGERP (CDR X))) 0)
	((NOT (MEVENP (CAR X))) 
	 (COND ((NULL RATCOEFF) NIL)
	       ((ALIKE1 (CDR X) '((RAT) 1 2))
		(POWER -1 (ADD RATCOEFF -1//2)))))
	((OR (ALIKE1 '((RAT) 1 6) (SETQ X (MMOD (CDR X) 2))) (ALIKE1 '((RAT) 5 6) X)) 1//2)
	((OR (ALIKE1 '((RAT) 1 4) X) (ALIKE1 '((RAT) 3 4) X)) (DIV (POWER 2 1//2) 2))
	((OR (ALIKE1 '((RAT) 1 3) X) (ALIKE1 '((RAT) 2 3) X)) (DIV (POWER 3 1//2) 2))
	((ALIKE1 1//2 X) 1)
	((OR (ALIKE1 '((RAT) 7 6) X) (ALIKE1 '((RAT) 11 6) X)) -1//2)
	((OR (ALIKE1 '((RAT) 4 3) X) (ALIKE1 '((RAT) 5 3) X)) (DIV (POWER 3 1//2) -2))
	((OR (ALIKE1 '((RAT) 5 4) X) (ALIKE1 '((RAT) 7 4) X)) (MUL -1//2 (POWER 2 1//2)))
	((ALIKE1 '((RAT) 3 2) X) -1)))

(DEFUN LINEARIZE (FORM)
  (COND ((INTEGERP FORM) (CONS 0 FORM))
	((NUMBERP FORM) NIL)
	((ATOM FORM)
	 (LET (DUM)
	   (COND ((SETQ DUM (EVOD FORM))
		  (IF (EQ '$EVEN DUM) '(2 . 0) '(2 . 1)))
		 ((MAXIMA-INTEGERP FORM) '(1 . 0)))))
	((EQ 'RAT (CAAR FORM)) (CONS 0 FORM))
	((EQ 'MPLUS (CAAR FORM)) (LIN-MPLUS FORM))
	((EQ 'MTIMES (CAAR FORM)) (LIN-MTIMES FORM))
	((EQ 'MEXPT (CAAR FORM)) (LIN-MEXPT FORM))))

(DEFUN LIN-MPLUS (FORM)
  (DO ((TL (CDR FORM) (CDR TL)) (DUMMY) (COEFF 0) (zl-REM 0))
      ((NULL TL) (CONS COEFF (MMOD zl-REM COEFF)))
      (SETQ DUMMY (LINEARIZE (CAR TL)))
      (IF (NULL DUMMY) (RETURN NIL)
	  (SETQ COEFF (RGCD (CAR DUMMY) COEFF) zl-REM (RPLUS (CDR DUMMY) zl-REM)))))

(DEFUN LIN-MTIMES (FORM)
  (DO ((FL (CDR FORM) (CDR FL)) (DUMMY) (COEFF 0) (zl-REM 1))
      ((NULL FL) (CONS COEFF (MMOD zl-REM COEFF)))
      (SETQ DUMMY (LINEARIZE (CAR FL)))
      (COND ((NULL DUMMY) (RETURN NIL))
	    (T (SETQ COEFF (RGCD (RTIMES COEFF (CAR DUMMY))
				(RGCD (RTIMES COEFF (CDR DUMMY)) (RTIMES zl-REM (CAR DUMMY))))
		     zl-REM (RTIMES (CDR DUMMY) zl-REM))))))

(DEFUN LIN-MEXPT (FORM)
  (PROG (DUMMY)
	(COND ((AND (INTEGERP (CADDR FORM)) (NOT (MINUSP (CADDR FORM)))
		    (NOT (NULL (SETQ DUMMY (LINEARIZE (CADR FORM))))))
	       (RETURN (CONS (CAR DUMMY) (MMOD (CDR DUMMY) (CADDR FORM))))))))

#-cl
(DEFUN LCM (X Y) (QUOTIENT (TIMES X Y) (GCD X Y)))

(DEFUN RGCD (X Y)
  (COND ((INTEGERP X)
	 (COND ((INTEGERP Y) (GCD X Y))
	       (T (LIST '(RAT) (GCD X (CADR Y)) (CADDR Y)))))
	((INTEGERP Y) (LIST '(RAT) (GCD (CADR X) Y) (CADDR X)))
	(T (LIST '(RAT) (GCD (CADR X) (CADR Y)) (LCM (CADDR X) (CADDR Y))))))

(DEFUN MAXIMA-REDUCE (X Y)
  (PROG (GCD)
	(SETQ GCD (GCD X Y) X (QUOTIENT X GCD) Y (QUOTIENT Y GCD))
	(IF (MINUSP Y) (SETQ X (MINUS X) Y (MINUS Y)))
	(RETURN (IF (EQUAL Y 1) X (LIST '(RAT SIMP) X Y)))))

;; The following four functions are generated in code by TRANSL. - JPG 2/1/81

(DEFMFUN RPLUS (X Y) (ADDK X Y))

(DEFMFUN RDIFFERENCE (X Y) (ADDK X (TIMESK -1 Y)))

(DEFMFUN RTIMES (X Y) (TIMESK X Y))

(DEFMFUN RREMAINDER (X Y)
  (COND ((EQUAL 0 Y) (DBZ-ERR))
	((INTEGERP X)
	 (COND ((INTEGERP Y) (MAXIMA-REDUCE X Y))
	       (T (MAXIMA-REDUCE (TIMES X (CADDR Y)) (CADR Y)))))
	((INTEGERP Y) (MAXIMA-REDUCE (CADR X) (TIMES (CADDR X) Y)))
	(T (MAXIMA-REDUCE (TIMES (CADR X) (CADDR Y)) (TIMES (CADDR X) (CADR Y))))))

(DEFMFUN $EXPONENTIALIZE (EXP)
 (LET ($DEMOIVRE)
      (COND ((ATOM EXP) EXP)
	    ((TRIGP (CAAR EXP))
	     (EXPONENTIALIZE (CAAR EXP) ($EXPONENTIALIZE (CADR EXP))))
	    (T (RECUR-APPLY #'$EXPONENTIALIZE EXP)))))

(DEFMFUN EXPONENTIALIZE (OP ARG)
  (COND ((EQ '%SIN OP)
	 (DIV (SUB (POWER '$%E (MUL '$%I ARG)) (POWER '$%E (MUL -1 '$%I ARG)))
		      (MUL 2 '$%I)))
	((EQ '%COS OP)
	 (DIV (ADD (POWER '$%E (MUL '$%I ARG)) (POWER '$%E (MUL -1 '$%I ARG))) 2))
	((EQ '%TAN OP)
	 (DIV (SUB (POWER '$%E (MUL '$%I ARG)) (POWER '$%E (MUL -1 '$%I ARG)))
		      (MUL '$%I (ADD (POWER '$%E (MUL '$%I ARG))
					      (POWER '$%E (MUL -1 '$%I ARG))))))
	((EQ '%COT OP)
	 (DIV (MUL '$%I (ADD (POWER '$%E (MUL '$%I ARG))
					      (POWER '$%E (MUL -1 '$%I ARG))))
		      (SUB (POWER '$%E (MUL '$%I ARG)) (POWER '$%E (MUL -1 '$%I ARG)))))
	((EQ '%CSC OP)
	 (DIV (MUL 2 '$%I)
		      (SUB (POWER '$%E (MUL '$%I ARG)) (POWER '$%E (MUL -1 '$%I ARG)))))
	((EQ '%SEC OP)
	 (DIV 2 (ADD (POWER '$%E (MUL '$%I ARG)) (POWER '$%E (MUL -1 '$%I ARG)))))
	((EQ '%SINH OP)
	 (DIV (SUB (POWER '$%E ARG) (POWER '$%E (NEG ARG))) 2))
	((EQ '%COSH OP)
	 (DIV (ADD (POWER '$%E ARG) (POWER '$%E (MUL -1 ARG))) 2))
	((EQ '%TANH OP)
	 (DIV (SUB (POWER '$%E ARG) (POWER '$%E (NEG ARG)))
		      (ADD (POWER '$%E ARG) (POWER '$%E (MUL -1 ARG)))))
	((EQ '%COTH OP)
	 (DIV (ADD (POWER '$%E ARG) (POWER '$%E (MUL -1 ARG)))
		      (SUB (POWER '$%E ARG) (POWER '$%E (NEG ARG)))))
	((EQ '%CSCH OP)
	 (DIV 2 (SUB (POWER '$%E ARG) (POWER '$%E (NEG ARG)))))
	((EQ '%SECH OP)
	 (DIV 2 (ADD (POWER '$%E ARG) (POWER '$%E (MUL -1 ARG)))))))

(DEFUN COEFFICIENT (EXP VAR POW) (COEFF (EXPAND1 EXP 1 0) VAR POW))

(DEFUN MMOD (X MOD)
  (COND ((and (INTEGERP X) (INTEGERP mod))
		(IF (MINUSP (if (zerop mod) x (SETQ X (f- X (f* MOD (// X MOD))))))
		    (f+ X MOD)
		    X))
        ((and ($ratnump x) ($ratnump mod))
			   (let
			       ((d (lcm ($denom x) ($denom mod))))
			     (setq x (mul* d x))
			     (setq mod (mul* d mod))
			     (div (mod x mod) d)))
	(t nil)))
;	((AND (NOT (ATOM X)) (EQ 'RAT (CAAR X)))
;	 (LIST '(RAT) (MMOD (CADR X) (f* MOD (CADDR X))) (CADDR X))


(DEFUN MULTIPLEP (EXP VAR)
  (AND (NOT (ZEROP1 EXP)) (ZEROP1 (SUB EXP (MUL VAR (COEFF EXP VAR 1))))))

(DEFUN LINEARP (EXP VAR)
 (AND (SETQ EXP (ISLINEAR (EXPAND1 EXP 1 0) VAR)) (NOT (EQUAL (CAR EXP) 0))))

(DEFMFUN MMINUSP (X) (= -1 (SIGNUM1 X)))

(DEFMFUN MMINUSP* (X)
 (LET (SIGN)
      (SETQ SIGN (CSIGN X))
      (OR (MEMQ SIGN '($NEG $NZ))
	  (AND (MMINUSP X) (NOT (MEMQ SIGN '($POS $PZ)))))))

;; This should give more information somehow.

(DEFUN DBZ-ERR ()
 (COND ((NOT ERRORSW) (MERROR "Division by zero"))
       (T (THROW 'ERRORSW T))))

(DEFUN DBZ-ERR1 (FUNC)
 (COND ((NOT ERRORSW) (MERROR "Division by zero in ~A function" FUNC))
       (T (THROW 'ERRORSW T))))

;; Only used by LAP code right now.

#+PDP10
(DEFUN NUMERIC-ERR (X MSG) (MERROR "~A in ~A function" MSG X))

;; Trig, hyperbolic functions, and inverses, which take real floating args
;; and return real args.  Checks made for overflow and out of range args.
;; The following are read-time constants.
;; This seems bogus.  Probably want (FSC (LSH 1 26.) 0) for the PDP10. -cwh

#.(SETQ EPS #+PDP10 (FSC 1.0 -26.)
	    #+cl ;(ASH 1.0 #+3600 -24. #-3600 -31.)
	    (scale-float 1.0 -24)
            #-(or PDP10 Cl) 1.4E-8)

#-cl ;;it already has a value thank you very much
(SETQ PI #.(ATAN 0.0 -1.0))
(eval-when (load eval compile)
  (defvar piby2 (coerce (/ pi 2.0) 'double-float)))

;; This function is in LAP for PDP10 systems.  On the Lisp Machine and
;; in NIL, this should CONDITION-BIND the appropriate arithmetic overflow
;; signals and do whatever NUMERIC-ERR or DBZ-ERR does.  Fix later.

#-(OR PDP10 CL) (DEFMACRO T//$ (X Y FUNCTION) FUNCTION ;Ignored
			     `(//$ ,X ,Y))
#+CL
(DEFMACRO T//$ (X Y FUNCTION)
  (IF (EQUAL Y 0.0)
      ;; DEFEAT INCOMPETENTLY DONE COMPILER:OPTIMIZATION.
      `(T//$-FOO ,X ,Y ,FUNCTION)
      `(//$ ,X ,Y)))
#+CL
(DEFUN T//$-FOO (X Y FUNCTION) FUNCTION
       (//$ X Y))

#+PDP10 (LAP-A-LIST '(

(LAP 	T//$ SUBR)
(ARGS 	T//$ (NIL . 3))
	(PUSH P (% 0 0 FLOAT1))
	(JRST 2 @ (% 0 0 NEXTA))
NEXTA	(MOVE TT 0 A)
	(FDVR TT 0 B)			;DIVIDE TT BY SECOND ARG
	(JFCL 10 UFLOW)
ANS	(POPJ P)
UFLOW	(MOVE A C)
	(SKIPN 0 0 B)
	 (JCALL 1 'DBZ-ERR1)
	(MOVEI B 'OVERFLOW)
	(JSP T NEXTB)
NEXTB	(TLNN T 64.)
	 (JCALL 2 'NUMERIC-ERR)
	(MOVEI B 'UNDERFLOW)
	(SKIPN 0 (SPECIAL ZUNDERFLOW))
	 (JCALL 2 'NUMERIC-ERR)
	(MOVEI TT 0)
	(JRST 0 ANS)
NIL ))

;; Numeric functions (SIN, COS, LOG, EXP are built in to Lisp).

(DEFMFUN TAN (X) (T//$ (SIN X) (COS X) 'TAN))

(DEFMFUN COT (X) (T//$ (COS X) (SIN X) 'COT))

(DEFMFUN SEC (X) (T//$ 1.0 (COS X) 'SEC))

(DEFMFUN CSC (X) (T//$ 1.0 (SIN X) 'CSC))

;; #.<form> means to evaluate <form> at read-time.

(DECLARE-TOP (FLONUM YY YFLO))

#-Franz
(DEFMFUN ASIN (NUM)
  (LET ((YFLO (FLOAT NUM)))
    (COND ((> (ABS YFLO) 1.0) (LOGARC '%ASIN YFLO))
	  ((< (ABS YFLO) #.(SQRT EPS)) YFLO)
	  (T (*$ (ATAN (ABS YFLO) (SQRT (-$ 1.0 (*$ YFLO YFLO))))
		 (IF (< YFLO 0.0) -1.0 1.0))))))

#-Franz
(DEFMFUN ACOS (NUM) 
  (LET ((YFLO (FLOAT NUM)))
    (COND ((> (ABS YFLO) 1.0) (LOGARC '%ACOS YFLO))
	  ((< (ABS YFLO) #.(SQRT EPS)) (-$ #.PIBY2 YFLO))
	  (T (ATAN (SQRT (-$ 1.0 (*$ YFLO YFLO))) YFLO)))))

#+MACLISP
(DEFUN ATAN2 (Y X)
  (LET ((YFLO (ATAN (ABS Y) X))) (IF (MINUSP Y) (-$ YFLO) YFLO)))

(DEFMFUN ATAN1 (NUM)
   (LET ((YFLO (FLOAT NUM)))
	(*$ (ATAN (ABS YFLO) 1.0) (IF (MINUSP YFLO) -1.0 1.0))))

(DEFMFUN ACOT (NUM)
   (LET ((YFLO (FLOAT NUM)))
	(*$ (ATAN 1.0 (ABS YFLO)) (IF (MINUSP YFLO) -1.0 1.0))))

(DEFMFUN ASEC (NUM)
   (LET ((YFLO (FLOAT NUM)))
	(IF (< (ABS YFLO) 1.0) (LOGARC '%ASEC YFLO)) (ACOS (//$ YFLO))))

(DEFMFUN ACSC (NUM)
   (LET ((YFLO (FLOAT NUM)))
	(IF (< (ABS YFLO) 1.0) (LOGARC '%ACSC YFLO)) (ASIN (//$ YFLO))))

(DEFMFUN SINH (NUM)
  (LET ((YY (FLOAT NUM)) (YFLO 0.0))
    (COND ((< (ABS YY) #.(SQRT EPS)) YY)
	  (T (SETQ YFLO (EXP (ABS YY)) YFLO (//$ (-$ YFLO (//$ YFLO)) 2.0))
	     (IF (< YY 0.0) (-$ YFLO) YFLO)))))

(DEFMFUN COSH (NUM)
   (LET ((YFLO (FLOAT NUM)))
	(SETQ YFLO (EXP (ABS YFLO))) (//$ (+$ YFLO (//$ YFLO)) 2.0)))

(DEFMFUN TANH (NUM)
  (LET ((YY (FLOAT NUM)) (YFLO 0.0))
    (COND ((< (ABS YY) #.(SQRT EPS)) YY)
	  (T (SETQ YFLO (EXP (*$ -2.0 (ABS YY))) YFLO (//$ (1-$ YFLO) (1+$ YFLO)))
	     (IF (PLUSP YY) (-$ YFLO) YFLO)))))

(DEFMFUN COTH (NUM)
  (LET ((YY (FLOAT NUM)) (YFLO 0.0))
    (COND ((< (ABS YY) #.(SQRT EPS)) (//$ YY))
	  (T (SETQ YFLO (EXP (*$ -2.0 (ABS YY))) YFLO (T//$ (1+$ YFLO) (1-$ YFLO) 'COTH))
	     (IF (PLUSP YY) (-$ YFLO) YFLO)))))

(DEFMFUN CSCH (NUM)
  (LET ((YY (FLOAT NUM)) (YFLO 0.0))
    (COND ((< (ABS YY) #.(SQRT EPS)) (//$ YY))
	  (T (SETQ YFLO (EXP (-$ (ABS YY)))
		   YFLO (T//$ (*$ 2.0 YFLO)
			      (1-$ (IF (< YFLO #.(SQRT EPS)) 0.0 (*$ YFLO YFLO))) 'CSCH))
	     (IF (PLUSP YY) (-$ YFLO) YFLO)))))

(DEFMFUN SECH (NUM)
  (LET ((YFLO (FLOAT NUM))) (SETQ YFLO (EXP (-$ (ABS YFLO))))
    (//$ YFLO 0.5 (1+$ (IF (< YFLO #.(SQRT EPS)) 0.0 (*$ YFLO YFLO))))))

(DEFMFUN ACOSH (NUM)
   (LET ((YFLO (FLOAT NUM)))
     (COND ((< YFLO 1.0) (LOGARC '%ACOSH YFLO))
	   ((> YFLO #.(SQRT (//$ EPS))) (LOG (*$ 2.0 YFLO)))
	   (T (LOG (+$ (SQRT (1-$ (*$ YFLO YFLO))) YFLO))))))

(DEFMFUN ASINH (NUM)
   (LET* ((YY (FLOAT NUM))
	  (YFLO (ABS YY)))
	 (COND ((< YFLO #.(SQRT EPS)) YFLO)
	       (T (SETQ YFLO (LOG (COND ((> YFLO #.(SQRT (//$ EPS))) (*$ 2.0 YFLO))
				     (T (+$ (SQRT (1+$ (*$ YFLO YFLO))) YFLO)))))
		  (COND ((MINUSP YY) (-$ YFLO)) (T YFLO))))))

(DEFMFUN ATANH (NUM)
   (LET ((YFLO (FLOAT NUM)))
     (COND ((< (ABS YFLO) #.(SQRT EPS)) YFLO)
	   ((< (ABS YFLO) 1.0) (//$ (LOG (T//$ (1+$ YFLO) (-$ 1.0 YFLO) 'ATANH)) 2.0))
	   ((= 1.0 (ABS YFLO)) (T//$ 1.0 0.0 'ATANH))
	   (T (LOGARC '%ATANH YFLO)))))

(DEFMFUN ACOTH (NUM)
   (LET ((YFLO (FLOAT NUM)))
     (COND ((> (ABS YFLO) 1.0)
	    (//$ (LOG (//$ (+$ 1.0 YFLO) (+$ -1.0 YFLO))) 2.0))
	   ((= 1.0 (ABS YFLO)) (T//$ 1.0 0.0 'ACOTH))
	   (T (LOGARC '%ACOTH YFLO)))))

(DEFMFUN ASECH (NUM)
   (LET ((YFLO (FLOAT NUM)))
	(COND ((OR (MINUSP YFLO) (> YFLO 1.0)) (LOGARC '%ASECH YFLO)))
	(ACOSH (T//$ 1.0 YFLO 'ASECH))))

(DEFMFUN ACSCH (NUM) (ASINH (T//$ 1.0 (FLOAT NUM) 'ACSCH)))

