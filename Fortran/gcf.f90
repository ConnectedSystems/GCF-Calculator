program gcf
    implicit none
    integer, allocatable :: search_vals(:)
    integer :: nums_to_process
    integer :: i, val, res, ans, ans2
    
    interface
       function gcf_recursive(x1, x2) result(res)
         integer :: res
         integer, intent(in) :: x1, x2
       end function gcf_recursive
    end interface

    ! Some other implementations of interest perhaps: https://rosettacode.org/wiki/Greatest_common_divisor#Recursive_Euclid_algorithm_3
    print *, 'How many numbers do you want to process?'
    read(*, *) nums_to_process
    print *, 'Enter these numbers, but beware they must be positive integers or I will crash'
    allocate(search_vals(nums_to_process))
    read(*, *) (search_vals(i), i=1,nums_to_process) 
    
    !search_vals = (/ 1600, 1200, 800 /)
    
    ! Manual implementation of reduce
    do i = 1, size(search_vals) - 1
        if( i == 1 ) then
            val = gcf_recursive(search_vals(i), search_vals(i+1))
        else
            res = gcf_recursive(val, search_vals(i+1))
            val = res
        end if
    end do
    
    print *, 'The answer you seek is: ', val

end program

recursive function gcf_recursive(x1, x2) result(res)

    integer, intent(in):: x1, x2
    integer :: res
    if (x2 == 0) then
        res = x1
    else
        res = gcf_recursive(x2, mod(x1, x2))
    end if

end function gcf_recursive