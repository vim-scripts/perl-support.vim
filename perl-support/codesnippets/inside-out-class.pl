
#===============================================================================
#        Class: ClassName
#  Description: 
#===============================================================================
package ClassName;

use Class::Std::Utils;                      # Utilities for building inside-out-objects


{
    # Objects of this class have the following attributes:
    my  %attribute1;

    #---------------------------------------------------------------------------
    #  constructor
    #---------------------------------------------------------------------------
    sub new {
        my  ( $class, @arg )    = @_;

        my  $object_ref = bless \do{ my $anonymous_scalar; }, $class;

        # initialize attribute 1
        $attribute1{ident $object_ref}  = $arg[0];

        return $object_ref;
    }   # ----------  end of subroutine new  ----------

    #---------------------------------------------------------------------------
    #  destructor
    #---------------------------------------------------------------------------
    sub DESTROY {
        my  ($self) = @_;
        delete $attribute1{ident $self};        # clean up attribute 
        return ;
    }   # ----------  end of subroutine DESTROY  ----------

    #---------------------------------------------------------------------------
    #  read accessor : attribute1
    #---------------------------------------------------------------------------
    sub get_attribute1 {
        my  ($self) = @_;
        return $attribute1{ident $self};
    }   # ----------  end of subroutine get_attribute1  ----------
