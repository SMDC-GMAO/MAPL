! This module re-exports the public entities
! of the underlying packages.
module MAPL
   use MAPLBase_mod
   use MAPL_GenericMod
   use MAPL_VarSpecMiscMod
   use ESMF_CFIOMod
   use pFIO
   use MAPL_GridCompsMod
   use mapl_StubComponent
   use MAPL_ESMFFieldBundleRead
   use MAPL_ESMFFieldBundleWrite
   use MAPL_OpenMP_Support, only : MAPL_get_current_thread => get_current_thread
   use MAPL_OpenMP_Support, only : MAPL_get_num_threads => get_num_threads
   use MAPL_OpenMP_Support, only : MAPL_find_bounds => find_bounds
   use MAPL_OpenMP_Support, only : MAPL_Interval => Interval
   use MAPL_Profiler, initialize_profiler =>initialize, finalize_profiler =>finalize
   use MAPL_FieldUtils
   use MAPL_StateUtils
   implicit none
end module MAPL

module MAPL_Mod
   use MAPL
end module MAPL_Mod
   
