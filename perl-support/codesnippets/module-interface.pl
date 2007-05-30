
package PackageName;

use strict;
use warnings;

#=======================================================================
#  MODULE INTERFACE
#=======================================================================

use version; our $VERSION = qv('0.2.0');

use base qw(Exporter);

# Symbols to be exported by default
our @EXPORT     = qw();

# Symbols to be exported on request
our @EXPORT_OK  = qw();

# Define names for sets of symbols
%EXPORT_TAGS    = (
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
#  MODULE IMPLEMENTATION
#=======================================================================

END { }                                         # module clean-up code

  1;
