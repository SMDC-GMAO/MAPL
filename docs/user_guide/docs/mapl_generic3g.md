# MAPL Generic3G Module Documentation

## Overview

The `mapl3g_Generic` module (`generic3g/MAPL_Generic.F90`) provides a comprehensive set of procedures designed to be called from within user-level gridded components in the MAPL framework. This module serves as a collection of thin wrapper procedures that access the internal private state of gridded components and invoke methods on those types.

## Purpose and Design

The primary purpose of this module is to provide backward compatibility with earlier MAPL versions while maintaining a clean interface for gridded component operations. The procedures in this module handle:

- Gridded component configuration and management
- Resource access and configuration
- Child component management
- State and geometry handling
- Connection management between components
- Internal state access

**Note:** Unlike MAPL2, which provided both gridcomp and meta overloads for many procedures, MAPL3G implements "meta" interfaces as object-oriented methods in either InnerMetaComponent or OuterMetaComponent classes.

## Module Dependencies

The module imports functionality from several MAPL3G modules:
- `mapl3g_InnerMetaComponent` and `mapl3g_OuterMetaComponent` - Core meta component classes
- `mapl3g_ChildSpec`, `mapl3g_ComponentSpec`, `mapl3g_VariableSpec` - Specification types
- `mapl3g_StateRegistry`, `mapl3g_VerticalGrid` - Grid and state management
- ESMF framework components for Earth System modeling
- MAPL error handling and logging utilities

## Public Interface Overview

### Core Component Management

| Interface | Purpose |
|-----------|---------|
| `MAPL_GridCompGetOuterMeta` | Retrieve outer meta component |
| `MAPL_GridCompGetRegistry` | Access state registry |
| `MAPL_GridCompGet` | Get component properties |
| `MAPL_GridCompSet` | Configure component settings |
| `MAPL_GridCompIsGeneric` | Check if component is generic |
| `MAPL_GridCompIsUser` | Check if component is user-defined |
| `MAPL_GridCompGetInternalState` | Access internal component state |

### Component Specification and Configuration

| Interface | Purpose |
|-----------|---------|
| `MAPL_GridCompAddVarSpec` | Add variable specifications |
| `MAPL_GridCompAddSpec` | Add component specifications |
| `MAPL_GridCompSetEntryPoint` | Configure component entry points |
| `MAPL_GridcompGetResource` | Retrieve configuration resources |

### Child Component Management

| Interface | Purpose |
|-----------|---------|
| `MAPL_GridCompAddChild` | Add child components |
| `MAPL_GridCompRunChild` | Execute single child component |
| `MAPL_GridCompRunChildren` | Execute all child components |

### Geometry and Grid Management

| Interface | Purpose |
|-----------|---------|
| `MAPL_GridCompSetGeometry` | Set component geometry |
| `MAPL_GridCompSetGeom` | Set various geometry types (Grid, Mesh, Xgrid, LocStream) |
| `MAPL_GridCompSetVerticalGrid` | Configure vertical grid structure |

### Component Connections

| Interface | Purpose |
|-----------|---------|
| `MAPL_GridCompAddConnectivity` | Add component connections |
| `MAPL_GridCompReexport` | Re-export component data |
| `MAPL_GridCompConnectAll` | Connect all compatible components |

### Utility Functions

| Interface | Purpose |
|-----------|---------|
| `MAPL_ClockGet` | Access timing information |

### Constants

| Constant | Purpose |
|----------|---------|
| `MAPL_STATEITEM_STATE`, `MAPL_STATEITEM_FIELDBUNDLE` | State item type constants |
| `MAPL_RESTART`, `MAPL_RESTART_SKIP` | Restart behavior constants |

## Detailed Interface Documentation

### MAPL_GridCompGet

Gets various properties from a gridded component.

**Interface:**
```fortran
call MAPL_GridCompGet(gridcomp, &
     hconfig=hconfig, &
     logger=logger, &
     geom=geom, &
     grid=grid, &
     num_levels=num_levels, &
     rc=rc)
```

**Parameters:**
- `gridcomp` (ESMF_GridComp, inout): The gridded component
- `hconfig` (ESMF_HConfig, optional, out): Component configuration
- `logger` (Logger_t, optional, pointer, out): Logger instance
- `geom` (ESMF_Geom, optional, out): Component geometry
- `grid` (ESMF_Grid, optional, out): ESMF grid object
- `num_levels` (integer, optional, out): Number of vertical levels
- `rc` (integer, optional, out): Return code

### MAPL_GridCompSet

Configures various settings for a gridded component.

**Interface:**
```fortran
call MAPL_GridCompSet(gridcomp, &
     activate_all_exports=activate_all_exports, &
     activate_all_imports=activate_all_imports, &
     write_exports=write_exports, &
     cold_start=cold_start, &
     rc=rc)
```

**Parameters:**
- `gridcomp` (ESMF_GridComp, inout): The gridded component
- `activate_all_exports` (logical, optional, in): Enable all exports
- `activate_all_imports` (logical, optional, in): Enable all imports
- `write_exports` (logical, optional, in): Enable export writing
- `cold_start` (logical, optional, in): Configure for cold start
- `rc` (integer, optional, out): Return code

### MAPL_GridCompAddChild

Adds a child component to a parent gridded component. This interface has two variants:

#### Variant 1: Using Configuration
```fortran
call MAPL_GridCompAddChild(gridcomp, child_name, setservices, hconfig, &
     timeStep=timeStep, refTime_offset=refTime_offset, rc=rc)
```

#### Variant 2: Using Specification
```fortran
call MAPL_GridCompAddChild(gridcomp, child_name, child_spec, rc=rc)
```

**Parameters:**
- `gridcomp` (ESMF_GridComp, inout): Parent gridded component
- `child_name` (character, in): Name of the child component
- `setservices` (AbstractUserSetServices, in): Set services procedure
- `hconfig` (ESMF_HConfig, in): Child configuration
- `child_spec` (ChildSpec, in): Child component specification
- `timeStep` (ESMF_TimeInterval, optional, in): Component time step
- `refTime_offset` (ESMF_TimeInterval, optional, in): Reference time offset
- `rc` (integer, optional, out): Return code

### MAPL_GridCompSetGeom

Sets the geometry for a gridded component. This interface supports multiple geometry types:

```fortran
! For general geometry
call MAPL_GridCompSetGeom(gridcomp, geom, rc=rc)

! For ESMF Grid
call MAPL_GridCompSetGeom(gridcomp, grid, rc=rc)

! For ESMF Mesh
call MAPL_GridCompSetGeom(gridcomp, mesh, rc=rc)

! For ESMF Xgrid
call MAPL_GridCompSetGeom(gridcomp, xgrid, rc=rc)

! For ESMF LocStream
call MAPL_GridCompSetGeom(gridcomp, locstream, rc=rc)
```

### MAPL_GridCompGetResource

Retrieves configuration resources with type-specific overloads for different data types:

```fortran
! For integers (4-byte and 8-byte)
call MAPL_GridCompGetResource(gc, keystring, value, default=default, rc=rc)

! For reals (4-byte and 8-byte)
call MAPL_GridCompGetResource(gc, keystring, value, default=default, rc=rc)

! For logical values
call MAPL_GridCompGetResource(gc, keystring, value, default=default, rc=rc)

! For strings
call MAPL_GridCompGetResource(gc, keystring, value, default=default, rc=rc)

! For sequences/arrays
call MAPL_GridCompGetResource(gc, keystring, values, default=default, rc=rc)
```

**Parameters:**
- `gc` (ESMF_GridComp, inout): Gridded component
- `keystring` (character, in): Configuration key name
- `value`/`values`: Output value(s) of appropriate type
- `default` (optional, in): Default value if key not found
- `value_set` (logical, optional, out): Whether value was found
- `rc` (integer, optional, out): Return code

## Usage Examples

### Basic Component Setup

```fortran
use mapl3g_Generic
type(ESMF_GridComp) :: gridcomp
type(ESMF_HConfig) :: config
type(ESMF_Geom) :: geom
integer :: rc

! Get component configuration
call MAPL_GridCompGet(gridcomp, hconfig=config, geom=geom, rc=rc)

! Configure component for cold start
call MAPL_GridCompSet(gridcomp, cold_start=.true., rc=rc)
```

### Adding and Running Child Components

```fortran
use mapl3g_Generic
type(ESMF_GridComp) :: parent_comp
type(ESMF_HConfig) :: child_config
character(len=*), parameter :: child_name = "ChildComponent"
integer :: rc

! Add a child component
call MAPL_GridCompAddChild(parent_comp, child_name, my_setservices, &
                          child_config, rc=rc)

! Run the child component
call MAPL_GridCompRunChild(parent_comp, child_name, rc=rc)

! Or run all children
call MAPL_GridCompRunChildren(parent_comp, rc=rc)
```

### Resource Access

```fortran
use mapl3g_Generic
type(ESMF_GridComp) :: gridcomp
integer :: my_integer_value
real :: my_real_value
character(len=256) :: my_string_value
logical :: found_value
integer :: rc

! Get integer resource with default
call MAPL_GridCompGetResource(gridcomp, "MY_INTEGER_KEY", my_integer_value, &
                              default=42, value_set=found_value, rc=rc)

! Get real resource
call MAPL_GridCompGetResource(gridcomp, "MY_REAL_KEY", my_real_value, rc=rc)

! Get string resource
call MAPL_GridCompGetResource(gridcomp, "MY_STRING_KEY", my_string_value, &
                              default="default_value", rc=rc)
```

## Error Handling

All procedures in this module follow MAPL's error handling conventions:
- Optional `rc` (return code) parameter for status reporting
- Use of `_RC` macro for internal error propagation
- Consistent error status values following ESMF conventions

## Backward Compatibility

This module maintains backward compatibility with earlier MAPL versions by preserving familiar procedure names and interfaces. However, some functionality has been restructured:
- Meta component operations are now object-oriented methods
- Some overloaded interfaces have been simplified
- Internal implementation uses MAPL3G architecture

## Related Modules

- `mapl3g_InnerMetaComponent` - Inner meta component functionality
- `mapl3g_OuterMetaComponent` - Outer meta component functionality
- `mapl3g_ComponentSpec` - Component specification types
- `mapl3g_StateRegistry` - State management
- `mapl3g_VerticalGrid` - Vertical grid handling

## See Also

- MAPL User Guide for comprehensive framework documentation
- ESMF documentation for underlying Earth System Modeling Framework
- MAPL3G architecture documentation for design principles