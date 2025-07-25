#include "MAPL_ErrLog.h"
module MAPL_ApplicationSupport
 use MPI
 use MAPL_ExceptionHandling
 use MAPL_KeywordEnforcerMod
 use pflogger, only: logging
 use pflogger, only: Logger
 use udunits2f, initialize_udunits => initialize, finalize_udunits => finalize
 use MAPL_Profiler, initialize_profiler =>initialize, finalize_profiler =>finalize

 implicit none
 private

 public MAPL_Initialize
 public MAPL_Finalize

 contains

   subroutine MAPL_Initialize(unusable,comm,logging_config,rc)
      class (KeywordEnforcer), optional, intent(in) :: unusable
      integer, optional, intent(in) :: comm
      character(len=*), optional,intent(in) :: logging_config
      integer, optional, intent(out) :: rc

      character(:), allocatable :: logging_configuration_file
      integer :: comm_world,status

      _UNUSED_DUMMY(unusable)

      if (present(logging_config)) then
         logging_configuration_file=logging_config
      else
         logging_configuration_file=''
      end if
      if (present(comm)) then
         comm_world = comm
      else
         comm_world=MPI_COMM_WORLD
      end if
#ifdef BUILD_WITH_PFLOGGER
      call initialize_pflogger(comm=comm_world,logging_config=logging_configuration_file,rc=status)
      _VERIFY(status)
#endif
      call initialize_profiler(comm=comm_world)
      call start_global_time_profiler(rc=status)
      _VERIFY(status)
      call initialize_udunits(_RC)
      _RETURN(_SUCCESS)

   end subroutine MAPL_Initialize

   subroutine MAPL_Finalize(unusable,comm,rc)
      class (KeywordEnforcer), optional, intent(in) :: unusable
      integer, optional, intent(in) :: comm
      integer, optional, intent(out) :: rc

      integer :: comm_world,status

      _UNUSED_DUMMY(unusable)

      call finalize_udunits()
      if (present(comm)) then
         comm_world = comm
      else
         comm_world=MPI_COMM_WORLD
      end if
      call stop_global_time_profiler(rc=status)
      _VERIFY(status)
      call report_global_profiler(comm=comm_world)
      call finalize_profiler()
      call finalize_pflogger()
      _RETURN(_SUCCESS)

   end subroutine MAPL_Finalize

   subroutine finalize_pflogger()
      call logging%free()
   end subroutine finalize_pflogger

#ifdef BUILD_WITH_PFLOGGER
   subroutine initialize_pflogger(unusable,comm,logging_config,rc)
      use pflogger, only: pfl_initialize => initialize
      use pflogger, only: StreamHandler, FileHandler, HandlerVector
      use pflogger, only: MpiLock, MpiFormatter
      use pflogger, only: INFO, WARNING
      use PFL_Formatter, only: get_sim_time
      use mapl_SimulationTime, only: fill_time_dict

      use, intrinsic :: iso_fortran_env, only: OUTPUT_UNIT

      class (KeywordEnforcer), optional, intent(in) :: unusable
      integer, optional, intent(in) :: comm
      character(len=*), optional,intent(in) :: logging_config
      integer, optional, intent(out) :: rc

      type (HandlerVector) :: handlers
      type (StreamHandler) :: console
      type (FileHandler) :: file_handler
      integer :: level,rank,status
      character(:), allocatable :: logging_configuration_file
      integer :: comm_world
      type(Logger), pointer :: lgr

      _UNUSED_DUMMY(unusable)
      if (present(logging_config)) then
         logging_configuration_file=logging_config
      else
         logging_configuration_file=''
      end if
      if (present(comm)) then
         comm_world = comm
      else
         comm_world=MPI_COMM_WORLD
      end if

      call pfl_initialize()
      get_sim_time => fill_time_dict

      if (logging_configuration_file /= '') then
         call logging%load_file(logging_configuration_file)
      else

         call MPI_COMM_Rank(comm_world,rank,status)
         _VERIFY(status)
         console = StreamHandler(OUTPUT_UNIT)
         call console%set_level(INFO)
         call console%set_formatter(MpiFormatter(comm_world, fmt='%(short_name)a10~: %(message)a'))
         call handlers%push_back(console)

         file_handler = FileHandler('warnings_and_errors.log')
         call file_handler%set_level(WARNING)
         call file_handler%set_formatter(MpiFormatter(comm_world, fmt='pe=%(mpi_rank)i5.5~: %(short_name)a~: %(message)a'))
         call file_handler%set_lock(MpiLock(comm_world))
         call handlers%push_back(file_handler)

         if (rank == 0) then
            level = INFO
         else
            level = WARNING
         end if

         call logging%basic_config(level=level, handlers=handlers, rc=status)
         _VERIFY(status)

         if (rank == 0) then
            lgr => logging%get_logger('MAPL')
            call lgr%warning('No configure file specified for logging layer.  Using defaults.')
         end if

      end if
      _RETURN(_SUCCESS)

   end subroutine initialize_pflogger
#endif

   subroutine report_global_profiler(unusable,comm,rc)
      class (KeywordEnforcer), optional, intent(in) :: unusable
      integer, optional, intent(in) :: comm
      integer, optional, intent(out) :: rc
      type (ProfileReporter) :: reporter
      integer :: i, world_comm
      character(:), allocatable :: report_lines(:)
      type (MultiColumn) :: inclusive
      type (MultiColumn) :: exclusive
      integer :: npes, my_rank, ierror
      character(1) :: empty(0)
      class (BaseProfiler), pointer :: t_p
      type(Logger), pointer :: lgr

      _UNUSED_DUMMY(unusable)
      if (present(comm)) then
         world_comm = comm
      else
         world_comm=MPI_COMM_WORLD
      end if
      t_p => get_global_time_profiler()

      reporter = ProfileReporter(empty)
      call reporter%add_column(NameColumn(50, separator= " "))
      call reporter%add_column(FormattedTextColumn('#-cycles','(i8.0)', 8, NumCyclesColumn(),separator='-'))

      inclusive = MultiColumn(['Inclusive'], separator='=')
      call inclusive%add_column(FormattedTextColumn(' T (sec) ','(f9.3)', 9, InclusiveColumn(), separator='-'))
      call inclusive%add_column(FormattedTextColumn('   %  ','(f6.2)', 6, PercentageColumn(InclusiveColumn(),'MAX'),separator='-'))
      call reporter%add_column(inclusive)

      exclusive = MultiColumn(['Exclusive'], separator='=')
      call exclusive%add_column(FormattedTextColumn(' T (sec) ','(f9.3)', 9, ExclusiveColumn(), separator='-'))
      call exclusive%add_column(FormattedTextColumn('   %  ','(f6.2)', 6, PercentageColumn(ExclusiveColumn()), separator='-'))
      call reporter%add_column(exclusive)

      call MPI_Comm_size(world_comm, npes, ierror)
      _VERIFY(ierror)
      call MPI_Comm_Rank(world_comm, my_rank, ierror)
      _VERIFY(ierror)

      if (my_rank == 0) then
         report_lines = reporter%generate_report(t_p)
         lgr => logging%get_logger('MAPL.profiler')
         call lgr%info('Report on process: %i0', my_rank)
         do i = 1, size(report_lines)
            call lgr%info('%a', report_lines(i))
         end do
      end if
      call MPI_Barrier(world_comm, ierror)
      _VERIFY(ierror)

      _RETURN(_SUCCESS)
   end subroutine report_global_profiler

end module MAPL_ApplicationSupport
