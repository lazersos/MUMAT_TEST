PROGRAM MUMATERIAL_TEST
   USE MUMATERIAL_MOD
   IMPLICIT NONE
   INCLUDE "mpif.h"


   INTEGER :: istat, size, rank, comm
   CHARACTER(LEN=256) :: filename

   DOUBLE PRECISION, DIMENSION(:), allocatable :: x, y, z, Hx, Hy, Hz, offset
   INTEGER :: i_int
   DOUBLE PRECISION :: Bx, By, Bz
   INTEGER :: start, finish, rate

   integer, parameter :: arg_len = 256

   INTEGER :: i, numargs
   CHARACTER*(arg_len) :: arg1
   CHARACTER*(arg_len), allocatable, dimension(:) :: args

   rank = 0

    !-----------------------------------------------------------------------
    !     Handle Input Arguments
    !-----------------------------------------------------------------------
    numargs = 0
    i = 0
    arg1 = ''
    ! First Handle the input arguments
    CALL GETCARG(1, arg1, numargs)
    ALLOCATE(args(numargs))
    ! Cycle through Arguments
    i = 1
    DO WHILE (i <= numargs)
       call GETCARG(i, args(i), numargs)
       select case (args(i))
          case ("-mumat")
                i = i + 1
                CALL GETCARG(i, filename, numargs)
       END SELECT
       i = i + 1
    END DO
    DEALLOCATE(args)

   CALL MPI_INIT(istat)
   comm = MPI_COMM_WORLD
   CALL MPI_COMM_SIZE(comm, size, istat)
   CALL MPI_COMM_RANK(comm, rank, istat)

   IF (rank .eq. 0) THEN
      CALL SYSTEM_CLOCK(count_rate=rate)
      CALL SYSTEM_CLOCK(start)
   END IF
      !filename = 'sphere_mu.dat'

      allocate(offset(3))
      offset = [0.0, 0.0, 0.0]

      CALL MUMATERIAL_LOAD(TRIM(filename),istat, comm)
      ! if (istat/=0) EXIT(2) ! probably need to stop the program in this case?

      IF (rank .eq. 0) THEN
         CALL MUMATERIAL_INFO(6)
      END IF

      CALL MUMATERIAL_SETD(1.0d-5, 1000, 0.7d0, 0.75d0, 2000, comm) ! only set if values need to be changed

      CALL MUMATERIAL_INIT(BEXTERNAL, comm, offset)

      IF (rank .eq. 0) THEN
         CALL SYSTEM_CLOCK(finish)
         WRITE(*,*) "Time to finish loading: ", real(finish-start)/real(rate)
      END IF
      
      CALL gen_grid(x, y, z)

      ! CALL MUMATERIAL_GETB(5.d0, 5.d0, 501.d0, Bx, By, Bz, BEXTERNAL)
      ! WRITE(*,*) "H:", Bx / (16 * atan(1.d0) * 1.d-7), By / (16 * atan(1.d0) * 1.d-7), Bz / (16 * atan(1.d0) * 1.d-7)
      
      CALL MUMATERIAL_OUTPUT('./', x, y, z, BEXTERNAL, comm)

      IF (rank .eq. 0) THEN
         CALL SYSTEM_CLOCK(finish)
         WRITE(*,*) "Time to finish: ", real(finish-start)/real(rate)
      END IF

   CALL MPI_FINALIZE(istat)

   CONTAINS

   SUBROUTINE BEXTERNAL(x,y,z,bx,by,bz)
      IMPLICIT NONE
      DOUBLE PRECISION, INTENT(IN) :: x,y,z
      DOUBLE PRECISION, INTENT(OUT) :: bx,by,bz
      DOUBLE PRECISION :: theta, phi, mag

      ! python easy axis from spherical coordinate transformations
      theta = 0.0
      phi = 0.0
      mag = 1.0!16 * atan(1.d0) * 1.0E-7
      bx = mag*sin(theta)*cos(phi)
      by = mag*sin(theta)*sin(phi)
      bz = mag*cos(theta)

      !bx = 1.0; by = 0.0; bz = 0.0

      RETURN
   END SUBROUTINE BEXTERNAL

   subroutine gen_grid(x, y, z)
      implicit none
      DOUBLE PRECISION, dimension(:), allocatable, intent(out) :: x, y, z
      integer, dimension(3) :: num_points
      integer :: n_temp, i, j, k, n_points
      DOUBLE PRECISION :: r, theta, phi, pi
      DOUBLE PRECISION, dimension(3) :: min, max

      pi = 4.0 * atan(1.0)
      
      min = [5.0, 0.0, 0.0]
      max = [1000.d0, pi, 2.0*pi]
      num_points = [300, 5, 1]![200, 5, 1]
      ! min = [-10.0, -10.0, -10.0]
      ! max = [10.0, 10.0, 10.0]
      ! num_points = [300, 300, 300]
      
      n_temp = 1
      n_points = num_points(1)*num_points(2)*num_points(3)
      allocate(x(n_points))
      allocate(y(n_points))
      allocate(z(n_points))

      do i = 1, num_points(1)
         do j = 1, num_points(2)
               do k = 1, num_points(3)
                  if (num_points(1) .gt. 1) then
                     r = min(1) + 1.0*(i-1)*(max(1)-min(1))/(num_points(1)-1)
                     x(n_temp) = min(1) + 1.0*(i-1)*(max(1)-min(1))/(num_points(1)-1)
                  else
                     r = min(1)
                     x(n_temp) = min(1)
                  end if
                  if (num_points(2) .gt. 1) then
                     theta = min(2) + 1.0*(j-1)*(max(2)-min(2))/(num_points(2)-1)
                     y(n_temp) = min(2) + 1.0*(j-1)*(max(2)-min(2))/(num_points(2)-1)
                  else
                     theta = min(2)
                     y(n_temp) = min(2)
                  end if
                  if (num_points(3) .gt. 1) then
                     phi = min(3) + 1.0*(k-1)*(max(3)-min(3))/(num_points(3))
                     z(n_temp) = min(3) + 1.0*(k-1)*(max(3)-min(3))/(num_points(3)-1)
                  else
                     phi = min(3)
                     z(n_temp) = min(3)
                  end if
                  x(n_temp) = r*sin(theta)*cos(phi)
                  y(n_temp) = r*sin(theta)*sin(phi)
                  z(n_temp) = r*cos(theta)
                  n_temp = n_temp + 1
               enddo
         enddo
      enddo
   end subroutine gen_grid

END PROGRAM MUMATERIAL_TEST