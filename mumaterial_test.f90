PROGRAM MUMATERIAL_TEST
   USE MUMATERIAL_MOD
   IMPLICIT NONE


   INTEGER :: istat
   CHARACTER(LEN=72) :: filename


   filename = 'sphere_mu.dat'

   CALL MUMATERIAL_LOAD(FILENAME,istat)

   ! Now call your other routiens


   CONTAINS

   SUBROUTINE BEXTERNAL(x,y,z,bx,by,bz)
      IMPLICIT NONE
      DOUBLE PRECISION, INTENT(IN) :: x,y,z
      DOUBLE PRECISION, INTENT(OUT) :: bx,by,bz

      bx = 1.0; by = 0.0; bz = 0.0

      RETURN
   END SUBROUTINE BEXTERNAL

END PROGRAM MUMATERIAL_TEST
