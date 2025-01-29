##################################################
# Variables
#
open := if os() == "linux" {
  "xdg-open"
} else if os() == "macos" {
  "open"
} else {
  "start \"\" /max"
}

project_dir   := justfile_directory()
project_name  := file_stem(justfile_directory())
project_tag   := "0.1.0"

typst_version := "typst -V"
typst_github  := "https://github.com/typst/typst --tag v0.12.0"

option_script := "scripts/change-options.bash"
template_dir  := join(justfile_directory(), "template")
doc_name      := "report"
type          := "draft"
lang          := "en"

local_dir      := "~/Library/Application\\ Support/typst/packages/local"
preview_dir    := "~/work/repo/edu/template/packages/packages/preview"

##################################################
# COMMANDS
#
# List all commands
@default:
  just --list

# Information about the environment
@info:
  echo "Environment Informations\n------------------------\n"
  echo "    OS          : {{os()}}({{arch()}})"
  echo "    Open        : {{open}}"
  echo "    Typst       : `{{typst_version}}`"
  echo "    Projectdir  : {{project_dir}}"
  echo "    Projectname : {{project_name}}"

# install required sw
[windows]
[linux]
@install:
  echo "Install typst"
  cargo install --git {{typst_github}}

# install required sw
[macos]
@install:
  echo "Install typst"
  brew install typst

# install the template locally as local package
[macos]
@copy-local:
  echo "Install template locally as local"
  mkdir -p {{local_dir}}/{{project_name}}/{{project_tag}}
  cp -r ./* {{local_dir}}/{{project_name}}/{{project_tag}}

# install the template locally as preview package
[macos]
@copy-preview:
  echo "Install template locally as preview"
  mkdir -p {{preview_dir}}/{{project_name}}/{{project_tag}}
  cp -r ./* {{preview_dir}}/{{project_name}}/{{project_tag}}

# generate changelog
@changelog:
  git-cliff --unreleased --tag {{project_tag}}

# generate changelog for the release
@changelog-released:
  git-cliff

# watch a typ file for continuous incremental build
watch file_name=doc_name:
  typst w {{template_dir}}/{{file_name}}.typ

# open pdf
open file_name=doc_name:
  pushd {{template_dir}}
  {{open}} {{file_name}}.pdf
  popd

# build, rename and copy a typ file to a pdf
@pdf file_name=doc_name type=type lang=lang:
  echo "--------------------------------------------------"
  echo "-- Generate {{file_name}}.pdf of type {{type}}"
  echo "--"
  pushd {{template_dir}}
  bash {{option_script}} -t {{type}} -l {{lang}}
  typst c {{file_name}}.typ
  just clean
  popd

# build, rename and copy a typ file in all variants
@pdf-all file_name=doc_name:
  echo "--------------------------------------------------"
  echo "-- Generate all variants of {{file_name}}.pdf"
  echo "--"
  just pdf {{file_name}} draft en
  just pdf {{file_name}} final en

# cleanup intermediate files
[linux]
[macos]
@clean:
  echo "--------------------------------------------------"
  echo "-- Clean {{project_name}}"
  echo "--"
  rm lib/*.pdf || true

# cleanup intermediate files
[windows]
@clean:
  echo "--------------------------------------------------"
  echo "-- Clean {{project_name}}"
  echo "--"
  del /q /s lib\*.pdf 2>nul
