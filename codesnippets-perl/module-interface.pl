
package PackageName;   

#-----------------------------------------------------------------------
#  MODULE INTERFACE
#-----------------------------------------------------------------------
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);

use Exporter;
$VERSION     = 1.00;                       # Or higher
@ISA         = qw(Exporter);

# Symbols to autoexport (:DEFAULT tag)
@EXPORT      = qw();

# Symbols to export on request
@EXPORT_OK   = qw();

# Define names for sets of symbols
%EXPORT_TAGS = (
  TAG1 => [],
  TAG2 => [],
  );

#-----------------------------------------------------------------------
#  MODULE CODE
#-----------------------------------------------------------------------


  1;
