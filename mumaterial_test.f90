PROGRAM MUMATERIAL_TEST
   USE MUMATERIAL_MOD
   IMPLICIT NONE


   INTEGER :: istat
   CHARACTER(LEN=256) :: filename

   DOUBLE PRECISION, DIMENSION(:), allocatable :: x, y, z, Hx, Hy, Hz, offset
   INTEGER :: i_int
   DOUBLE PRECISION :: Bx, By, Bz
   INTEGER :: start, finish, rate

   call SYSTEM_CLOCK(count_rate=rate)
   call SYSTEM_CLOCK(start)

   filename = 'sphere_mu.dat'

   allocate(offset(3))
   offset = [0.0, 0.0, 0.0]

   CALL MUMATERIAL_LOAD(TRIM(filename),istat)
   ! if (istat/=0) EXIT(2) ! probably need to stop the program in this case?

   CALL MUMATERIAL_INFO(6)

   !CALL MUMATERIAL_SETD(1.0d-5, 1000, 300.d0) ! only set if values need to be changed

   CALL MUMATERIAL_INIT(BEXTERNAL,offset)

   CALL SYSTEM_CLOCK(finish)
   WRITE(*,*) "Time to finish loading: ", real(finish-start)/real(rate)

   CALL gen_grid(x, y, z)

   CALL MUMATERIAL_GETB(5.d0, 5.d0, 501.d0, Bx, By, Bz)
   WRITE(*,*) "H:", Bx / (16 * atan(1.d0) * 1.d-7), By / (16 * atan(1.d0) * 1.d-7), Bz / (16 * atan(1.d0) * 1.d-7)
   
   CALL MUMATERIAL_OUTPUT('/home/bch/Documents/IPP/MUMAT_TEST', x, y, z)

   CALL SYSTEM_CLOCK(finish)
   WRITE(*,*) "Time to finish: ", real(finish-start)/real(rate)



   CONTAINS

   SUBROUTINE BEXTERNAL(x,y,z,bx,by,bz)
      IMPLICIT NONE
      DOUBLE PRECISION, INTENT(IN) :: x,y,z
      DOUBLE PRECISION, INTENT(OUT) :: bx,by,bz
      DOUBLE PRECISION :: theta, phi, mag

      ! python easy axis from spherical coordinate transformations
      theta = 0.0
      phi = 0.0
      mag = 1.0
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
      
      min = [550.0, 0.0, 0.0]
      max = [2000.d0, pi, pi]
      num_points = [200, 5, 1]
      ! min = [-20.0, -20.0, -20.0]
      ! max = [20.0, 20.0, 20.0]
      ! num_points = [100, 100, 100]
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
                  else
                     r = min(1)
                  end if
                  if (num_points(2) .gt. 1) then
                     theta = min(2) + 1.0*(j-1)*(max(2)-min(2))/(num_points(2)-1)
                  else
                     theta = min(2)
                  end if
                  if (num_points(3) .gt. 1) then
                     phi = min(3) + 1.0*(k-1)*(max(3)-min(3))/(num_points(3)-1)
                  else
                     phi = min(3)
                  end if
                  x(n_temp) = r*sin(theta)*cos(phi) + offset(1)
                  y(n_temp) = r*sin(theta)*sin(phi) + offset(2)
                  z(n_temp) = r*cos(theta) + offset(3)
                  ! x(n_temp) = min(1) + 1.0*(i-1)*(max(1)-min(1))/(num_points(1)-1) + offset(1)
                  ! y(n_temp) = min(2) + 1.0*(j-1)*(max(2)-min(2))/(num_points(2)-1) + offset(2)
                  ! z(n_temp) = min(3) + 1.0*(k-1)*(max(3)-min(3))/(num_points(3)-1) + offset(3)
                  n_temp = n_temp + 1
               enddo
         enddo
      enddo
   end subroutine gen_grid

END PROGRAM MUMATERIAL_TEST