#!/bin/bash
#===================================================================================
#
#         FILE:  install.sh
#
#        USAGE:  ./install.sh 
#
#     SYNOPSIS:  Install the Vim plugin perl-support.vim from the current directory
#
#  DESCRIPTION:  
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Dr.-Ing. Fritz Mehner (Mn), mehner@fh-swf.de
#      COMPANY:  FH Südwestfalen, Iserlohn
#      VERSION:  1.0
#      CREATED:  31.07.2003 16:52:26 CEST
#     REVISION:  ---
#===================================================================================

source_dir='.'              # the directory of this script
target=${1:-.vim}           # the local target directory (subdirectory .vim )
target_dir=$HOME/$target    # the complete target directory

#-----------------------------------------------------------------------
#  make directories
#-----------------------------------------------------------------------
mkdir  -p $target_dir
mkdir  -p $target_dir/doc
mkdir  -p $target_dir/ftplugin
mkdir  -p $target_dir/plugin
mkdir  -p $target_dir/plugin/templates
mkdir  -p $target_dir/wordlists
mkdir  -p $target_dir/codesnippets-perl


#-----------------------------------------------------------------------
#  copy files
#-----------------------------------------------------------------------
cp $source_dir/doc/perlsupport.txt   $target_dir/doc/

if [ -e $target_dir/ftplugin/perl.vim ]
then
  mv $target_dir/ftplugin/perl.vim $target_dir/ftplugin/perl.vim.save
fi

cp  $source_dir/ftplugin/perl.vim        $target_dir/ftplugin/
cp  $source_dir/doc/perlsupport.txt      $target_dir/doc/
cp  $source_dir/wordlists/perl.list      $target_dir/wordlists/
cp  $source_dir/plugin/perl-support.vim  $target_dir/plugin/
cp  $source_dir/plugin/templates/*       $target_dir/plugin/templates/

cat $source_dir/rc/perl.vimrc  >> $HOME/.vimrc

echo
echo "Don't forget to generate the local help tags file with the following Vim command:"
echo "  :helptags $target_dir"
echo
