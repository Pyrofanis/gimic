!
! GIMIC Fortran to C interface
!
! The routinese are to be used from C/C++ to access GIMIC functionality
!
module gimic_cif
    use globals_m  
    use settings_m  
    use teletype_m
    use basis_class
    use timer_m
    use cao2sao_class
    use basis_class
    use dens_class
    use jtensor_class
    use caos_m
    use gaussint_m
    implicit none

    type(molecule_t), save :: mol
    type(dens_t), save :: xdens
    type(cao2sao_t) :: c2s
    real(DP), dimension(3) :: magnet
    character(8) :: spin = 'total'
    type(jtensor_t) :: jtens
end module

subroutine gimic_init(molfile, densfile, spherical)
    use gimic_cif
    character(*), intent(in) :: molfile
    character(*), intent(in) :: densfile
    integer, optional :: spherical

    settings%basis=molfile
    settings%xdens=densfile
    settings%use_spherical=.false.
    if (present(spherical)) then
        if (spherical /= 0) then
            settings%use_spherical=.true.
        end if
    end if

    magnet=(/0.0, 0.0, 1.0/)
    settings%magnet=magnet
    settings%is_uhf=.false.
    settings%screen_thrs = SCREEN_THRS
    settings%use_giao = .true.
    settings%use_diamag = .true.
    settings%use_paramag = .true.
    settings%use_screening = .true.
    settings%lip_order = 5
    settings%mofile=""
    settings%morange=0
    settings%title=""
!    settings%density=""
!    settings%magnet_axis="X"

    call set_debug_level(3)
    if (settings%use_screening) then
        call new_basis(mol, settings%basis, settings%screen_thrs)
    else
        call new_basis(mol, settings%basis, -1.d0)
    end if

    if (settings%use_spherical) then
        call new_c2sop(c2s, mol)
        call set_c2sop(mol, c2s)
    end if

    call new_dens(xdens, mol)
    call read_dens(xdens, settings%xdens)
    call new_jtensor(jtens, mol, xdens)
end subroutine

subroutine gimic_finalize()
    use gimic_cif
    if (settings%use_spherical) then
        call del_c2sop(c2s)
    end if
    call del_dens(xdens)
    call del_basis(mol)
    call del_jtensor(jtens)
end subroutine

subroutine gimic_set_uhf(uhf)
    use gimic_cif
    integer, intent(in) :: uhf
    settings%is_uhf = .false.
    if (uhf /= 0) then
        settings%is_uhf = .true.
    end if
end subroutine

subroutine gimic_set_magnet(b)
    use gimic_cif
    real(8), dimension(3), intent(in) :: b
    settings%magnet = b
    magnet = b
end subroutine

subroutine gimic_set_spin(s)
    use gimic_cif
    character(*), intent(in) :: s
    select case (s)
        case ('alpha')
            spin = s
        case ('beta')
            spin = s
        case ('total')
            spin = s
        case ('spindens')
            spin = s
        case default
            stop 'Invalid spin case.'
    end select
end subroutine

subroutine gimic_set_screening(thrs)
    use gimic_cif
    real(8), intent(in) :: thrs
    settings%screen_thrs = thrs
end subroutine

subroutine gimic_calc_jtensor(r, jt)
    use gimic_cif
    real(8), dimension(3), intent(in) :: r
    real(8), dimension(9), intent(out) :: jt

    real(DP), dimension(9) :: t
    integer :: i,j,k

    call ctensor(jtens, r, t, spin)
    k=1
    do j=1,3
        do i=1,3
            jt(k)=t(i+(j-1)*3)
            k=k+1
        end do
    end do
end subroutine

subroutine gimic_calc_jvector(r, jv)
    use gimic_cif
    real(8), dimension(3), intent(in) :: r
    real(8), dimension(3), intent(out) :: jv

    call jvector(jtens, r, magnet, jv, spin)
end subroutine

subroutine gimic_calc_modj(r, dj)
    use gimic_cif
    real(8), dimension(3), intent(in) :: r
    real(8), intent(out) :: dj

    real(8), dimension(3) :: jv
    call jvector(jtens, r, magnet, jv, spin)
    dj = sqrt(sum(jv**2))
end subroutine

subroutine gimic_calc_anapole(r, dj)
    use gimic_cif
    real(8), dimension(3), intent(in) :: r
    real(8), intent(out) :: dj
    stop 'Not implemented yet'
end subroutine

subroutine gimic_calc_divj(r, dj)
    use gimic_cif
    use divj_m
    real(8), dimension(3), intent(in) :: r
    real(8), intent(out) :: dj

    dj = divj(r, magnet)
end subroutine

