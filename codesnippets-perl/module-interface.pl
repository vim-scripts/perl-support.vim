
package PackageName;   

#=======================================================================
#  MODULE INTERFACE
#=======================================================================

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
@ISA         = qw(Exporter);

$VERSION     = 1.00;                            # Version number

# Symbols to be exported by default
@EXPORT      = qw();

# Symbols to be exported on request
@EXPORT_OK   = qw();

# Define names for sets of symbols
%EXPORT_TAGS = (
  TAG1 => [],
  TAG2 => [],
  );

#=======================================================================
#  EXPORTED PACKAGE GLOBALS                       (listed in @EXPORT_OK)
#=======================================================================

#=======================================================================
#  NON=EXPORTED PACKAGE GLOBALS
#=======================================================================

#=======================================================================
#  MODULE CODE
#=======================================================================

END { }                                         # module clean-up code

  1;
