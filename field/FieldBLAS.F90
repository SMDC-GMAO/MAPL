#include "MAPL_Generic.h"

module mapl_FieldBLAS
   use ESMF
   use MAPL_ExceptionHandling
   use mapl3g_FieldCondensedArray
   use MAPL_FieldPointerUtilities
   implicit none
   private

   ! Level 1 BLAS (Basic Linear Algebra Subprograms)
   ! Available routines:
   !   FieldSCAL  - scale vector: x = a*x
   !   FieldAXPY  - add scaled vector: y = a*x + y  
   !   FieldSWAP  - interchange vectors: x <-> y
   !   FieldDOT   - dot product: result = x'*y
   !   FieldNRM2  - Euclidean norm: result = ||x||_2
   !   FieldASUM  - sum of absolute values: result = sum(|x_i|)
   !   FieldIAMAX - index of max absolute value: result = argmax(|x_i|)
   public :: FieldSCAL
   public :: FieldAXPY
   public :: FieldSWAP
   public :: FieldDOT
   public :: FieldNRM2
   public :: FieldASUM
   public :: FieldIAMAX

   ! Level 2 BLAS
   public :: FieldGEMV

!   ! Fortran intrinsics applied to fields
!   public :: Sin
!   public :: Cos
!   public :: Tan
!   public :: ASin
!   public :: ACos
!   public :: ATan
!   public :: Pow
!   public :: Abs
!   public :: Log
!   public :: Exp
!   public :: Log10
!   public :: Sqrt
!   public :: Sinh
!   public :: Cosh
!   public :: Tanh
!   public :: ASinh
!   public :: ACosh
!   public :: ATanh
!   public :: Heavyside


   ! Misc utiliities
   public :: FieldSpread
   public :: FieldConvertPrec

!wdb  fixme This acts on y in-place. Do we need a form that acts more like a function: y = FieldSCAL(a, x)?
   ! call FieldSCAL(a, x, rc): x = a*x (multiply x in-place)
   interface FieldSCAL
      procedure scale_r4
      procedure scale_r8
   end interface

   ! call FieldAXPY(a, x, y, rc): y = a*x + y (add a*x to y in-place)
   interface FieldAXPY
      procedure axpy_r4
      procedure axpy_r8
   end interface

   ! call FieldSWAP(x, y, rc): interchange x and y vectors
   interface FieldSWAP
      procedure swap_r4
      procedure swap_r8
   end interface

   ! result = FieldDOT(x, y, rc): compute dot product of x and y
   interface FieldDOT
      procedure dot_r4
      procedure dot_r8
   end interface

   ! result = FieldNRM2(x, rc): compute Euclidean norm of x
   interface FieldNRM2
      procedure nrm2_r4
      procedure nrm2_r8
   end interface

   ! result = FieldASUM(x, rc): compute sum of absolute values of x
   interface FieldASUM
      procedure asum_r4
      procedure asum_r8
   end interface

   ! result = FieldIAMAX(x, rc): find index of maximum absolute value in x
   interface FieldIAMAX
      procedure iamax_r4
      procedure iamax_r8
   end interface

   ! call FieldGEMV(alpha, A, x, beta, y, rc) (multiply y in-place, then add a*A*x to y in-place)
   interface FieldGEMV
      procedure gemv_r4
      procedure gemv_r8
   end interface

   interface FieldConvertPrec
      module procedure convert_prec
   end interface FieldConvertPrec

   interface FieldSpread
      module procedure spread_scalar
   end interface FieldSpread

   interface verify_typekind
      module procedure verify_typekind_scalar
      module procedure verify_typekind_array
   end interface verify_typekind

contains

   subroutine scale_r4(a, x, rc)
      real(kind=ESMF_KIND_R4), intent(in) :: a
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc

      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:)
      integer :: status

      call assign_fptr(x, x_ptr, _RC)
      x_ptr = a * x_ptr

      _RETURN(_SUCCESS)
   end subroutine scale_r4

   subroutine scale_r8(a, x, rc)
      real(kind=ESMF_KIND_R8), intent(in) :: a
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc

      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:)
      integer :: status

      call assign_fptr(x, x_ptr, _RC)
      x_ptr = a * x_ptr

      _RETURN(_SUCCESS)
   end subroutine scale_r8

   subroutine axpy_r4(a, x, y, rc)
      real(kind=ESMF_KIND_R4), intent(in) :: a
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_Field), intent(inout) :: y
      integer, optional, intent(out) :: rc

      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:), y_ptr(:)
      logical :: conformable
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R4)
      call verify_typekind(y, ESMF_TYPEKIND_R4)

      conformable = FieldsAreConformable(x, y)
      _ASSERT(conformable, 'FieldAXPY() - fields not conformable.')

      call assign_fptr(x, x_ptr, _RC)
      call assign_fptr(y, y_ptr, _RC)

      y_ptr = y_ptr + a * x_ptr

      _RETURN(_SUCCESS)
   end subroutine axpy_r4

   subroutine axpy_r8(a, x, y, rc)
      real(kind=ESMF_KIND_R8), intent(in) :: a
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_Field), intent(inout) :: y
      integer, optional, intent(out) :: rc

      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:), y_ptr(:)
      logical :: conformable
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R8)
      call verify_typekind(y, ESMF_TYPEKIND_R8)

      conformable = FieldsAreConformable(x, y)
      _ASSERT(conformable, 'FieldAXPY() - fields not conformable.')

      call assign_fptr(x, x_ptr, _RC)
      call assign_fptr(y, y_ptr, _RC)

      y_ptr = y_ptr + a * x_ptr

      _RETURN(_SUCCESS)
   end subroutine axpy_r8

   subroutine swap_r4(x, y, rc)
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_Field), intent(inout) :: y
      integer, optional, intent(out) :: rc

      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:), y_ptr(:)
      real(kind=ESMF_KIND_R4), allocatable :: temp_array(:)
      logical :: conformable
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R4)
      call verify_typekind(y, ESMF_TYPEKIND_R4)

      conformable = FieldsAreConformable(x, y)
      _ASSERT(conformable, 'FieldSWAP() - fields not conformable.')

      call assign_fptr(x, x_ptr, _RC)
      call assign_fptr(y, y_ptr, _RC)

      ! Swap by temporary storage
      allocate(temp_array(size(x_ptr)))
      temp_array = x_ptr
      x_ptr = y_ptr
      y_ptr = temp_array
      deallocate(temp_array)

      _RETURN(_SUCCESS)
   end subroutine swap_r4

   subroutine swap_r8(x, y, rc)
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_Field), intent(inout) :: y
      integer, optional, intent(out) :: rc

      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:), y_ptr(:)
      real(kind=ESMF_KIND_R8), allocatable :: temp_array(:)
      logical :: conformable
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R8)
      call verify_typekind(y, ESMF_TYPEKIND_R8)

      conformable = FieldsAreConformable(x, y)
      _ASSERT(conformable, 'FieldSWAP() - fields not conformable.')

      call assign_fptr(x, x_ptr, _RC)
      call assign_fptr(y, y_ptr, _RC)

      ! Swap by temporary storage
      allocate(temp_array(size(x_ptr)))
      temp_array = x_ptr
      x_ptr = y_ptr
      y_ptr = temp_array
      deallocate(temp_array)

      _RETURN(_SUCCESS)
   end subroutine swap_r8

      _RETURN(_SUCCESS)
   end subroutine swap_r8

   function dot_r4(x, y, rc) result(result_dot)
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_Field), intent(inout) :: y
      integer, optional, intent(out) :: rc
      real(kind=ESMF_KIND_R4) :: result_dot

      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:), y_ptr(:)
      logical :: conformable
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R4)
      call verify_typekind(y, ESMF_TYPEKIND_R4)

      conformable = FieldsAreConformable(x, y)
      _ASSERT(conformable, 'FieldDOT() - fields not conformable.')

      call assign_fptr(x, x_ptr, _RC)
      call assign_fptr(y, y_ptr, _RC)

      result_dot = dot_product(x_ptr, y_ptr)

      _RETURN(_SUCCESS)
   end function dot_r4

   function dot_r8(x, y, rc) result(result_dot)
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_Field), intent(inout) :: y
      integer, optional, intent(out) :: rc
      real(kind=ESMF_KIND_R8) :: result_dot

      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:), y_ptr(:)
      logical :: conformable
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R8)
      call verify_typekind(y, ESMF_TYPEKIND_R8)

      conformable = FieldsAreConformable(x, y)
      _ASSERT(conformable, 'FieldDOT() - fields not conformable.')

      call assign_fptr(x, x_ptr, _RC)
      call assign_fptr(y, y_ptr, _RC)

      result_dot = dot_product(x_ptr, y_ptr)

      _RETURN(_SUCCESS)
   end function dot_r8

   function nrm2_r4(x, rc) result(norm)
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc
      real(kind=ESMF_KIND_R4) :: norm

      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:)
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R4)

      call assign_fptr(x, x_ptr, _RC)

      norm = sqrt(dot_product(x_ptr, x_ptr))

      _RETURN(_SUCCESS)
   end function nrm2_r4

   function nrm2_r8(x, rc) result(norm)
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc
      real(kind=ESMF_KIND_R8) :: norm

      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:)
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R8)

      call assign_fptr(x, x_ptr, _RC)

      norm = sqrt(dot_product(x_ptr, x_ptr))

      _RETURN(_SUCCESS)
   end function nrm2_r8

   function asum_r4(x, rc) result(sum_abs)
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc
      real(kind=ESMF_KIND_R4) :: sum_abs

      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:)
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R4)

      call assign_fptr(x, x_ptr, _RC)

      sum_abs = sum(abs(x_ptr))

      _RETURN(_SUCCESS)
   end function asum_r4

   function asum_r8(x, rc) result(sum_abs)
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc
      real(kind=ESMF_KIND_R8) :: sum_abs

      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:)
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R8)

      call assign_fptr(x, x_ptr, _RC)

      sum_abs = sum(abs(x_ptr))

      _RETURN(_SUCCESS)
   end function asum_r8

   function iamax_r4(x, rc) result(max_index)
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc
      integer :: max_index

      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:)
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R4)

      call assign_fptr(x, x_ptr, _RC)

      max_index = maxloc(abs(x_ptr), dim=1)

      _RETURN(_SUCCESS)
   end function iamax_r4

   function iamax_r8(x, rc) result(max_index)
      type(ESMF_Field), intent(inout) :: x
      integer, optional, intent(out) :: rc
      integer :: max_index

      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:)
      integer :: status

      call verify_typekind(x, ESMF_TYPEKIND_R8)

      call assign_fptr(x, x_ptr, _RC)

      max_index = maxloc(abs(x_ptr), dim=1)

      _RETURN(_SUCCESS)
   end function iamax_r8

   ! Assumes gridded dimensions are first, and that the "vector" dim
   ! is last ungridded dim of fields.
   ! Computes y = alpha * A * x + beta * y

   ! [x,y,z] = A * [u,v]
   ! single precision (R4) gemv
   subroutine gemv_r4(trans, alpha, A, x, beta, y, rc)
      character(len=1), intent(in) :: trans
      real(kind=ESMF_KIND_R4), intent(in) :: alpha
      type(ESMF_Field), intent(inout) :: A(:,:)
      type(ESMF_Field), intent(inout) :: x(:)
      real(kind=ESMF_KIND_R4), intent(in) :: beta
      type(ESMF_Field), intent(inout) :: y(:)
      integer, optional, intent(out) :: rc

      logical :: conformable
      integer :: dimcount
      integer(kind=ESMF_KIND_I8) :: n_horz, n_vert, n_ungridded
      integer(kind=ESMF_KIND_I8) :: fp_shape(2)
      real(kind=ESMF_KIND_R4), pointer :: x_ptr(:,:), y_ptr(:,:) ! horz x (vert * ungridded)
      real(kind=ESMF_KIND_R8), pointer :: A_ptr(:) ! horz        ! horz
      real(kind=ESMF_KIND_R4), pointer :: tmp(:,:,:)
      integer :: ix, jy, kv
      integer :: condensed_shp(3)
      
      integer :: status

      select case (trans)
      case ('n','N')
         _ASSERT(size(A,2) == size(x), 'FieldGEMV() - array A not nonformable with x.')
         _ASSERT(size(A,1) == size(y), 'FieldGEMV() - array A not nonformable with y.')
      case ('t','T')
         _ASSERT(size(A,1) == size(x), 'FieldGEMV() - array A not nonformable with x.')
         _ASSERT(size(A,2) == size(y), 'FieldGEMV() - array A not nonformable with y.')
      case default
         _FAIL("unsupponted option for trans: '"//trans//"'")
      end select

      call verify_typekind(x, ESMF_TYPEKIND_R4)
      call verify_typekind(y, ESMF_TYPEKIND_R4)

      conformable = FieldsAreConformable(x(1), x(2:))
      _ASSERT(conformable, 'FieldGEMV() - fields not conformable.')
      conformable = FieldsAreConformable(x(1), y(:))
      _ASSERT(conformable, 'FieldGEMV() - fields not conformable.')

      ! Reference dimensions
      call assign_fptr_condensed_array(x(1), tmp, _RC)
      condensed_shp = shape(tmp)
      n_horz = condensed_shp(1)
      n_vert = condensed_shp(2)
      n_ungridded = condensed_shp(3)

!      y = matmul(A, x)
      do jy = 1, size(y)
         call assign_fptr(y(jy), [n_horz, n_vert*n_ungridded], y_ptr, _RC)
         y_ptr(:,:) = beta * y_ptr(:,:)

         do ix = 1, size(x)
            call assign_fptr(x(ix), [n_horz, n_vert*n_ungridded], x_ptr, _RC)
            select case (trans)
            case ('n','N')
               call assign_fptr(A(jy,ix), A_ptr, _RC) ! 1D - no shape arg
            case ('t','T')
               call assign_fptr(A(ix,jy), A_ptr, _RC) ! 1D - no shape arg
            end select
            do kv = 1, n_vert*n_ungridded
               y_ptr(:,kv) = y_ptr(:,kv) + alpha * A_ptr(:)*x_ptr(:,kv)
            end do

         end do
      end do

      _RETURN(_SUCCESS)
   end subroutine gemv_r4

   ! Double precision version (R8) of gemv. See gemv_r4 (single precision)

   subroutine gemv_r8(alpha, A, x, beta, y, rc)
      real(kind=ESMF_KIND_R8), intent(in) :: alpha
      real(kind=ESMF_KIND_R8), intent(in) :: A(:,:,:)
      type(ESMF_Field), intent(inout) :: x(:)
      real(kind=ESMF_KIND_R8), intent(in) :: beta
      type(ESMF_Field), intent(inout) :: y(:)
      integer, optional, intent(out) :: rc

      logical :: conformable
      integer :: dimcount
      integer, allocatable :: local_element_count(:)
      integer(kind=ESMF_KIND_I8) :: n_gridded, n_ungridded
      integer(kind=ESMF_KIND_I8) :: fp_shape(2)
      real(kind=ESMF_KIND_R8), pointer :: x_ptr(:,:), y_ptr(:,:)
      integer :: ix, jy, kv
      integer :: status

      _ASSERT(size(A,3) == size(x), 'FieldGEMV() - array A not nonformable with x.')
      _ASSERT(size(A,2) == size(y), 'FieldGEMV() - array A not nonformable with y.')

      call verify_typekind(x, ESMF_TYPEKIND_R8)
      call verify_typekind(y, ESMF_TYPEKIND_R8)

      conformable = FieldsAreConformable(x(1), x(2:))
      _ASSERT(conformable, 'FieldGEMV() - fields not conformable.')
      conformable = FieldsAreConformable(x(1), y)
      _ASSERT(conformable, 'FieldGEMV() - fields not conformable.')

      ! Reference dimensions
      local_element_count = FieldGetLocalElementCount(x(1), _RC)
      call ESMF_FieldGet(x(1), dimcount=dimcount, _RC)

      n_gridded = product(local_element_count(1:dimcount))
      n_ungridded = product(local_element_count(dimcount+1:))
      _ASSERT(size(A,1) == n_gridded, 'FieldGEMV() - array A not nonformable with gridded dims.')
      fp_shape = [n_gridded, n_ungridded]

!      y = matmul(A, x)
      do jy = 1, size(y)
         call assign_fptr(y(jy), fp_shape, y_ptr, _RC)
         y_ptr(:,jy) = beta * y_ptr(:,jy)
!         call FieldSCAL(beta, y_ptr(:,jy), _RC)

         do ix = 1, size(x)
            call assign_fptr(x(ix), fp_shape, x_ptr, _RC)
            do kv = 1, n_ungridded
               y_ptr(:,jy) = y_ptr(:,jy) + alpha * A(:,ix,jy) * x_ptr(:,kv)
            end do
         end do
      end do

      _RETURN(_SUCCESS)
   end subroutine gemv_r8

   function spread_scalar(source, ncopies, rc) result(vector)
      type(ESMF_Field), intent(inout) :: source
      integer, intent(in) :: ncopies
      integer, optional, intent(out) :: rc
      type(ESMF_Field), allocatable :: vector(:)
      integer :: i
      integer :: status

      _ASSERT(ncopies > 0, 'ncopies must be positive')

      allocate(vector(ncopies))

      do i=1, ncopies
         call FieldCOPY(source, vector(i), _RC)
      end do

      _RETURN(_SUCCESS)
   end function spread_scalar

   subroutine get_typekind(x, expected_tks, actual_tk, rc)
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_TypeKind_Flag), intent(in) :: expected_tks(:)
      type(ESMF_TypeKind_Flag), intent(out) :: actual_tk
      type(ESMF_TypeKind_Flag) :: found_tk
      integer, optional, intent(out) :: rc
      integer :: status
      integer :: i

      do i = 1, size(expected_tks)
         actual_tk = expected_tks(i)
         call ESMF_FieldGet(x, typekind=found_tk, _RC)
         if(actual_tk == found_tk) return
      end do

      _FAIL('Does not match any expected typekind')

   end subroutine get_typekind

    subroutine verify_typekind_scalar(x, expected_tk, rc)
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_TypeKind_Flag), intent(in) :: expected_tk
      integer, optional, intent(out) :: rc

      integer :: status

      type(ESMF_TypeKind_Flag) :: found_tk

      call ESMF_FieldGet(x, typekind=found_tk, _RC)

      _ASSERT((found_tk == expected_tk), 'Found incorrect typekind.')
      _RETURN(_SUCCESS)
   end subroutine verify_typekind_scalar

   subroutine verify_typekind_array(x, expected_tk, rc)
      type(ESMF_Field), intent(inout) :: x(:)
      type(ESMF_TypeKind_Flag), intent(in) :: expected_tk
      integer, optional, intent(out) :: rc

      integer :: status
      integer :: i

      do i = 1, size(x)
         call verify_typekind(x(i), expected_tk, _RC)
      end do
      _RETURN(_SUCCESS)
   end subroutine verify_typekind_array

!   subroutine verify_typekind_rank1(x, expected_tk, rc)
!      type(ESMF_Field), intent(inout) :: x(:)
!      type(ESMF_TypeKind_Flag), intent(in) :: expected_tk
!      integer, optional, intent(out) :: rc
!
!      integer :: status
!      integer :: i
!
!      do i = 1, size(x)
!         call verify_typekind(x(i), expected_tk, _RC)
!      end do
!
!      _RETURN(_SUCCESS)
!   end subroutine verify_typekind_rank1

   subroutine convert_prec(x, y, rc)
      type(ESMF_Field), intent(inout) :: x
      type(ESMF_Field), intent(inout) :: y
      integer, optional, intent(out) :: rc

      type(ESMF_TypeKind_Flag), parameter :: expected_tks(2) = [ESMF_TYPEKIND_R4, ESMF_TYPEKIND_R8]
      type(ESMF_TypeKind_Flag) :: tk_x, tk_y
      integer :: status

      call ESMF_FieldGet(x, typekind=tk_x, _RC)
      _ASSERT(is_valid_typekind(tk_x, expected_tks), 'Unexpected typekind')
      call ESMF_FieldGet(y, typekind=tk_y, _RC)
      _ASSERT(is_valid_typekind(tk_y, expected_tks), 'Unexpected typekind')

      if(tk_x == tk_y) then
         call FieldCOPY(x, y, _RC)
      else if(tk_x == ESMF_TYPEKIND_R4) then
         call convert_prec_R4_to_R8(x, y, _RC)
      else
         call convert_prec_R8_to_R4(x, y, _RC)
      end if

      _RETURN(_SUCCESS)
   end subroutine convert_prec

   function is_valid_typekind(actual_tk, valid_tks) result(is_valid)
      type(ESMF_TypeKind_Flag), intent(in) :: actual_tk
      type(ESMF_TypeKind_Flag), intent(in) :: valid_tks(:)
      logical :: is_valid
      integer :: i

      is_valid = .FALSE.
      do i = 1, size(valid_tks)
         is_valid = (actual_tk == valid_tks(i))
         if(is_valid) return
      end do

   end function is_valid_typekind

   subroutine convert_prec_R4_to_R8(original, converted, rc)
      type(ESMF_Field), intent(inout) :: original
      type(ESMF_Field), intent(inout) :: converted
      integer, optional, intent(out) :: rc
      integer :: status

      real(kind=ESMF_KIND_R4), pointer :: original_ptr(:)
      real(kind=ESMF_KIND_R8), pointer :: converted_ptr(:)

      call assign_fptr(original, original_ptr, _RC)
      call assign_fptr(converted, converted_ptr, _RC)

      converted_ptr = original_ptr

      _RETURN(_SUCCESS)
   end subroutine convert_prec_R4_to_R8

   subroutine convert_prec_R8_to_R4(original, converted, rc)
      type(ESMF_Field), intent(inout) :: original
      type(ESMF_Field), intent(inout) :: converted
      integer, optional, intent(out) :: rc
      integer :: status

      real(kind=ESMF_KIND_R8), pointer :: original_ptr(:)
      real(kind=ESMF_KIND_R4), pointer :: converted_ptr(:)

      call assign_fptr(original, original_ptr, _RC)
      call assign_fptr(converted, converted_ptr, _RC)

      converted_ptr = original_ptr

      _RETURN(_SUCCESS)
   end subroutine convert_prec_R8_to_R4

end module mapl_FieldBLAS
