#!/bin/sh

# Monoplex KR Generator
monoplex_kr_version="0.0.1"

base_dir=$(cd $(dirname $0); pwd)

# オプション解析
HIDDEN_SPACE_FLG='true'
NERDFONTS_FLG='false'
DEBUG_FLG='false'
PROGRESS_FLG='flase'
while getopts dsnp OPT
do
  case $OPT in
    'd' ) DEBUG_FLG='true';;
    's' ) HIDDEN_SPACE_FLG='false';;
    'n' ) NERDFONTS_FLG='true';;
    'p' ) PROGRESS_FLG='true';;
  esac
done

if [ "$DEBUG_FLG" = 'true' ]; then
  echo '### Debug Mode ###'
  sleep 2
fi
if [ "$HIDDEN_SPACE_FLG" = 'true' ]; then
  echo '### Generate Hidden Space Version ###'
  sleep 2
elif [ "$NERDFONTS_FLG" = 'true' ]; then
  echo '### Generate Nerd Fonts Version ###'
  sleep 2
fi

# Set familyname
hs_suffix=''
if [ "$HIDDEN_SPACE_FLG" = 'false' ]; then
  hs_suffix='SS'
elif [ "$NERDFONTS_FLG" = 'true' ]; then
  hs_suffix='Nerd'
fi
monoplex_kr_familyname="Monoplex KR"
monoplex_kr_familyname_suffix="${hs_suffix}"
monoplex_kr_wide_familyname="${monoplex_kr_familyname} Wide"
monoplex_kr_wide_familyname_suffix="${hs_suffix}"

# Set ascent and descent (line width parameters)
monoplex_kr_ascent=950
monoplex_kr_descent=225
monoplex_kr_wide_ascent=1025
monoplex_kr_wide_descent=275

em_ascent=880
em_descent=120
em=$(($em_ascent + $em_descent))

typo_line_gap=80

plexmono_width=600
plexkr_width=1000

monoplex_kr_half_width=528
monoplex_kr_full_width=$((${monoplex_kr_half_width} * 2))
plexmono_shrink_x=88
plexmono_shrink_y=94

monoplex_kr_wide_half_width=600
monoplex_kr_wide_full_width=$((${monoplex_kr_wide_half_width} * 5 / 3))

italic_angle=-9

end_plexmono=65535
end_plexkr=1115564

# Set path to fontforge command
fontforge_command="fontforge"
ttfautohint_command="ttfautohint"

# Set redirection of stderr
redirection_stderr="${base_dir}/error.log"

# Set fonts directories used in auto flag
fonts_directories="${base_dir}/source/ ${base_dir}/source/IBM-Plex-Mono/ ${base_dir}/source/IBM-Plex-Sans-KR/unhinted/"

# Set flags
leaving_tmp_flag="false"

# Set filenames
plexmono_thin_src="IBMPlexMono-Thin.ttf"
plexmono_extralight_src="IBMPlexMono-ExtraLight.ttf"
plexmono_light_src="IBMPlexMono-Light.ttf"
plexmono_regular_src="IBMPlexMono-Regular.ttf"
plexmono_text_src="IBMPlexMono-Text.ttf"
plexmono_medium_src="IBMPlexMono-Medium.ttf"
plexmono_semibold_src="IBMPlexMono-SemiBold.ttf"
plexmono_bold_src="IBMPlexMono-Bold.ttf"
plexmono_thin_italic_src="IBMPlexMono-ThinItalic.ttf"
plexmono_extralight_italic_src="IBMPlexMono-ExtraLightItalic.ttf"
plexmono_light_italic_src="IBMPlexMono-LightItalic.ttf"
plexmono_regular_italic_src="IBMPlexMono-Italic.ttf"
plexmono_text_italic_src="IBMPlexMono-TextItalic.ttf"
plexmono_medium_italic_src="IBMPlexMono-MediumItalic.ttf"
plexmono_semibold_italic_src="IBMPlexMono-SemiBoldItalic.ttf"
plexmono_bold_italic_src="IBMPlexMono-BoldItalic.ttf"

plexkr_thin_src="IBMPlexSansKR-Thin.ttf"
plexkr_extralight_src="IBMPlexSansKR-ExtraLight.ttf"
plexkr_light_src="IBMPlexSansKR-Light.ttf"
plexkr_regular_src="IBMPlexSansKR-Regular.ttf"
plexkr_text_src="IBMPlexSansKR-Text.ttf"
plexkr_medium_src="IBMPlexSansKR-Medium.ttf"
plexkr_semibold_src="IBMPlexSansKR-SemiBold.ttf"
plexkr_bold_src="IBMPlexSansKR-Bold.ttf"
plexkr_thin_italic_src="IBMPlexSansKR-ThinItalic.ttf"
plexkr_extralight_italic_src="IBMPlexSansKR-ExtraLightItalic.ttf"
plexkr_light_italic_src="IBMPlexSansKR-LightItalic.ttf"
plexkr_regular_italic_src="IBMPlexSansKR-Italic.ttf"
plexkr_text_italic_src="IBMPlexSansKR-TextItalic.ttf"
plexkr_medium_italic_src="IBMPlexSansKR-MediumItalic.ttf"
plexkr_semibold_italic_src="IBMPlexSansKR-SemiBoldItalic.ttf"
plexkr_bold_italic_src="IBMPlexSansKR-BoldItalic.ttf"

modified_plexmono_material_generator="modified_plexmono_material_generator.pe"
modified_plexmono_material_thin="Modified-IBMPlexMono-Material-thin.sfd"
modified_plexmono_material_extralight="Modified-IBMPlexMono-Material-extralight.sfd"
modified_plexmono_material_light="Modified-IBMPlexMono-Material-light.sfd"
modified_plexmono_material_regular="Modified-IBMPlexMono-Material-Regular.sfd"
modified_plexmono_material_text="Modified-IBMPlexMono-Material-text.sfd"
modified_plexmono_material_medium="Modified-IBMPlexMono-Material-medium.sfd"
modified_plexmono_material_semibold="Modified-IBMPlexMono-Material-semiBold.sfd"
modified_plexmono_material_bold="Modified-IBMPlexMono-Material-Bold.sfd"
modified_plexmono_material_thin_italic="Modified-IBMPlexMono-Material-thin_italic.sfd"
modified_plexmono_material_extralight_italic="Modified-IBMPlexMono-Material-extralight_italic.sfd"
modified_plexmono_material_light_italic="Modified-IBMPlexMono-Material-light_italic.sfd"
modified_plexmono_material_regular_italic="Modified-IBMPlexMono-Material-Regular_italic.sfd"
modified_plexmono_material_text_italic="Modified-IBMPlexMono-Material-text_italic.sfd"
modified_plexmono_material_medium_italic="Modified-IBMPlexMono-Material-medium_italic.sfd"
modified_plexmono_material_semibold_italic="Modified-IBMPlexMono-Material-semiBold_italic.sfd"
modified_plexmono_material_bold_italic="Modified-IBMPlexMono-Material-Bold_italic.sfd"

modified_plexmono_console_generator="modified_plexmono_console_generator.pe"
modified_plexmono_console_thin="Modified-IBMPlexMono-Console-thin.sfd"
modified_plexmono_console_extralight="Modified-IBMPlexMono-Console-extralight.sfd"
modified_plexmono_console_light="Modified-IBMPlexMono-Console-light.sfd"
modified_plexmono_console_regular="Modified-IBMPlexMono-Console-Regular.sfd"
modified_plexmono_console_text="Modified-IBMPlexMono-Console-text.sfd"
modified_plexmono_console_medium="Modified-IBMPlexMono-Console-medium.sfd"
modified_plexmono_console_semibold="Modified-IBMPlexMono-Console-semiBold.sfd"
modified_plexmono_console_bold="Modified-IBMPlexMono-Console-Bold.sfd"
modified_plexmono_console_thin_italic="Modified-IBMPlexMono-Console-thin_italic.sfd"
modified_plexmono_console_extralight_italic="Modified-IBMPlexMono-Console-extralight_italic.sfd"
modified_plexmono_console_light_italic="Modified-IBMPlexMono-Console-light_italic.sfd"
modified_plexmono_console_regular_italic="Modified-IBMPlexMono-Console-Regular_italic.sfd"
modified_plexmono_console_text_italic="Modified-IBMPlexMono-Console-text_italic.sfd"
modified_plexmono_console_medium_italic="Modified-IBMPlexMono-Console-medium_italic.sfd"
modified_plexmono_console_semibold_italic="Modified-IBMPlexMono-Console-semiBold_italic.sfd"
modified_plexmono_console_bold_italic="Modified-IBMPlexMono-Console-Bold_italic.sfd"

modified_plexmono35_console_generator="modified_plexmono35_console_generator.pe"
modified_plexmono35_console_thin="Modified-IBMPlexMono35-Console-thin.sfd"
modified_plexmono35_console_extralight="Modified-IBMPlexMono35-Console-extralight.sfd"
modified_plexmono35_console_light="Modified-IBMPlexMono35-Console-light.sfd"
modified_plexmono35_console_regular="Modified-IBMPlexMono35-Console-Regular.sfd"
modified_plexmono35_console_text="Modified-IBMPlexMono35-Console-text.sfd"
modified_plexmono35_console_medium="Modified-IBMPlexMono35-Console-medium.sfd"
modified_plexmono35_console_semibold="Modified-IBMPlexMono35-Console-semiBold.sfd"
modified_plexmono35_console_bold="Modified-IBMPlexMono35-Console-Bold.sfd"
modified_plexmono35_console_thin_italic="Modified-IBMPlexMono35-Console-thin_italic.sfd"
modified_plexmono35_console_extralight_italic="Modified-IBMPlexMono35-Console-extralight_italic.sfd"
modified_plexmono35_console_light_italic="Modified-IBMPlexMono35-Console-light_italic.sfd"
modified_plexmono35_console_regular_italic="Modified-IBMPlexMono35-Console-Regular_italic.sfd"
modified_plexmono35_console_text_italic="Modified-IBMPlexMono35-Console-text_italic.sfd"
modified_plexmono35_console_medium_italic="Modified-IBMPlexMono35-Console-medium_italic.sfd"
modified_plexmono35_console_semibold_italic="Modified-IBMPlexMono35-Console-semiBold_italic.sfd"
modified_plexmono35_console_bold_italic="Modified-IBMPlexMono35-Console-Bold_italic.sfd"

modified_plexmono_generator="modified_plexmono_generator.pe"
modified_plexmono_thin="Modified-IBMPlexMono-thin.sfd"
modified_plexmono_extralight="Modified-IBMPlexMono-extralight.sfd"
modified_plexmono_light="Modified-IBMPlexMono-light.sfd"
modified_plexmono_regular="Modified-IBMPlexMono-Regular.sfd"
modified_plexmono_text="Modified-IBMPlexMono-text.sfd"
modified_plexmono_medium="Modified-IBMPlexMono-medium.sfd"
modified_plexmono_semibold="Modified-IBMPlexMono-semiBold.sfd"
modified_plexmono_bold="Modified-IBMPlexMono-Bold.sfd"
modified_plexmono_thin_italic="Modified-IBMPlexMono-thin_italic.sfd"
modified_plexmono_extralight_italic="Modified-IBMPlexMono-extralight_italic.sfd"
modified_plexmono_light_italic="Modified-IBMPlexMono-light_italic.sfd"
modified_plexmono_regular_italic="Modified-IBMPlexMono-Regular_italic.sfd"
modified_plexmono_text_italic="Modified-IBMPlexMono-text_italic.sfd"
modified_plexmono_medium_italic="Modified-IBMPlexMono-medium_italic.sfd"
modified_plexmono_semibold_italic="Modified-IBMPlexMono-semiBold_italic.sfd"
modified_plexmono_bold_italic="Modified-IBMPlexMono-Bold_italic.sfd"

modified_plexmono35_generator="modified_plexmono35_generator.pe"
modified_plexmono35_thin="Modified-IBMPlexMono35-thin.sfd"
modified_plexmono35_extralight="Modified-IBMPlexMono35-extralight.sfd"
modified_plexmono35_light="Modified-IBMPlexMono35-light.sfd"
modified_plexmono35_regular="Modified-IBMPlexMono35-Regular.sfd"
modified_plexmono35_text="Modified-IBMPlexMono35-text.sfd"
modified_plexmono35_medium="Modified-IBMPlexMono35-medium.sfd"
modified_plexmono35_semibold="Modified-IBMPlexMono35-semiBold.sfd"
modified_plexmono35_bold="Modified-IBMPlexMono35-Bold.sfd"
modified_plexmono35_thin_italic="Modified-IBMPlexMono35-thin_italic.sfd"
modified_plexmono35_extralight_italic="Modified-IBMPlexMono35-extralight_italic.sfd"
modified_plexmono35_light_italic="Modified-IBMPlexMono35-light_italic.sfd"
modified_plexmono35_regular_italic="Modified-IBMPlexMono35-Regular_italic.sfd"
modified_plexmono35_text_italic="Modified-IBMPlexMono35-text_italic.sfd"
modified_plexmono35_medium_italic="Modified-IBMPlexMono35-medium_italic.sfd"
modified_plexmono35_semibold_italic="Modified-IBMPlexMono35-semiBold_italic.sfd"
modified_plexmono35_bold_italic="Modified-IBMPlexMono35-Bold_italic.sfd"

modified_plexkr_generator="modified_plexkr_generator.pe"
modified_plexkr_thin="Modified-IBMPlexSansKR-thin.sfd"
modified_plexkr_extralight="Modified-IBMPlexSansKR-extralight.sfd"
modified_plexkr_light="Modified-IBMPlexSansKR-light.sfd"
modified_plexkr_regular="Modified-IBMPlexSansKR-regular.sfd"
modified_plexkr_text="Modified-IBMPlexSansKR-text.sfd"
modified_plexkr_medium="Modified-IBMPlexSansKR-medium.sfd"
modified_plexkr_semibold="Modified-IBMPlexSansKR-semibold.sfd"
modified_plexkr_bold="Modified-IBMPlexSansKR-bold.sfd"
modified_plexkr_thin_italic="Modified-IBMPlexSansKR-thin_italic.sfd"
modified_plexkr_extralight_italic="Modified-IBMPlexSansKR-extralight_italic.sfd"
modified_plexkr_light_italic="Modified-IBMPlexSansKR-light_italic.sfd"
modified_plexkr_regular_italic="Modified-IBMPlexSansKR-regular_italic.sfd"
modified_plexkr_text_italic="Modified-IBMPlexSansKR-text_italic.sfd"
modified_plexkr_medium_italic="Modified-IBMPlexSansKR-medium_italic.sfd"
modified_plexkr_semibold_italic="Modified-IBMPlexSansKR-semibold_italic.sfd"
modified_plexkr_bold_italic="Modified-IBMPlexSansKR-bold_italic.sfd"

modified_plexkr_wide_generator="modified_plexkr_wide_generator.pe"
modified_plexkr_wide_thin="Modified-IBMPlexSanskr_wide-thin.sfd"
modified_plexkr_wide_extralight="Modified-IBMPlexSanskr_wide-extralight.sfd"
modified_plexkr_wide_light="Modified-IBMPlexSanskr_wide-light.sfd"
modified_plexkr_wide_regular="Modified-IBMPlexSanskr_wide-Monospace-regular.sfd"
modified_plexkr_wide_text="Modified-IBMPlexSanskr_wide-Monospace-text.sfd"
modified_plexkr_wide_medium="Modified-IBMPlexSanskr_wide-medium.sfd"
modified_plexkr_wide_semibold="Modified-IBMPlexSanskr_wide-semibold.sfd"
modified_plexkr_wide_bold="Modified-IBMPlexSanskr_wide-Monospace-bold.sfd"
modified_plexkr_wide_thin_italic="Modified-IBMPlexSanskr_wide-thin_italic.sfd"
modified_plexkr_wide_extralight_italic="Modified-IBMPlexSanskr_wide-extralight_italic.sfd"
modified_plexkr_wide_light_italic="Modified-IBMPlexSanskr_wide-light_italic.sfd"
modified_plexkr_wide_regular_italic="Modified-IBMPlexSanskr_wide-Monospace-regular_italic.sfd"
modified_plexkr_wide_text_italic="Modified-IBMPlexSanskr_wide-Monospace-text_italic.sfd"
modified_plexkr_wide_medium_italic="Modified-IBMPlexSanskr_wide-medium_italic.sfd"
modified_plexkr_wide_semibold_italic="Modified-IBMPlexSanskr_wide-semibold_italic.sfd"
modified_plexkr_wide_bold_italic="Modified-IBMPlexSanskr_wide-Monospace-bold_italic.sfd"

monoplex_kr_generator="monoplex_kr_generator.pe"
monoplex_kr_wide_generator="monoplex_kr_wide_generator.pe"

# Get input fonts
tmp=""
for i in $fonts_directories
do
    [ -d "${i}" ] && tmp="${tmp} ${i}"
done
fonts_directories="${tmp}"
# Search IBMPlexMono
input_plexmono_thin=`find $fonts_directories -follow -name "$plexmono_thin_src" | head -n 1`
input_plexmono_extralight=`find $fonts_directories -follow -name "$plexmono_extralight_src" | head -n 1`
input_plexmono_light=`find $fonts_directories -follow -name "$plexmono_light_src" | head -n 1`
input_plexmono_regular=`find $fonts_directories -follow -name "$plexmono_regular_src" | head -n 1`
input_plexmono_text=`find $fonts_directories -follow -name "$plexmono_text_src" | head -n 1`
input_plexmono_medium=`find $fonts_directories -follow -name "$plexmono_medium_src" | head -n 1`
input_plexmono_semibold=`find $fonts_directories -follow -name "$plexmono_semibold_src" | head -n 1`
input_plexmono_bold=`find $fonts_directories -follow -name "$plexmono_bold_src" | head -n 1`
input_plexmono_thin_italic=`find $fonts_directories -follow -name "$plexmono_thin_italic_src" | head -n 1`
input_plexmono_extralight_italic=`find $fonts_directories -follow -name "$plexmono_extralight_italic_src" | head -n 1`
input_plexmono_light_italic=`find $fonts_directories -follow -name "$plexmono_light_italic_src" | head -n 1`
input_plexmono_regular_italic=`find $fonts_directories -follow -name "$plexmono_regular_italic_src" | head -n 1`
input_plexmono_text_italic=`find $fonts_directories -follow -name "$plexmono_text_italic_src" | head -n 1`
input_plexmono_medium_italic=`find $fonts_directories -follow -name "$plexmono_medium_italic_src" | head -n 1`
input_plexmono_semibold_italic=`find $fonts_directories -follow -name "$plexmono_semibold_italic_src" | head -n 1`
input_plexmono_bold_italic=`find $fonts_directories -follow -name "$plexmono_bold_italic_src" | head -n 1`

input_r_thin=`find $fonts_directories -follow -name "r-Thin.sfd" | head -n 1`
input_r_extralight=`find $fonts_directories -follow -name "r-ExtraLight.sfd" | head -n 1`
input_r_light=`find $fonts_directories -follow -name "r-Light.sfd" | head -n 1`
input_r_regular=`find $fonts_directories -follow -name "r-Regular.sfd" | head -n 1`
input_r_text=`find $fonts_directories -follow -name "r-Text.sfd" | head -n 1`
input_r_medium=`find $fonts_directories -follow -name "r-Medium.sfd" | head -n 1`
input_r_semibold=`find $fonts_directories -follow -name "r-SemiBold.sfd" | head -n 1`
input_r_bold=`find $fonts_directories -follow -name "r-Bold.sfd" | head -n 1`

if [ -z "${input_plexmono_regular}" -o -z "${input_plexmono_bold}" ]
then
  echo "Error: $plexmono_regular_src and/or $plexmono_bold_src not found" >&2
  exit 1
fi

# Search IBMPlexSansKR
input_plexkr_thin=`find $fonts_directories -follow -iname "$plexkr_thin_src" | head -n 1`
input_plexkr_extralight=`find $fonts_directories -follow -iname "$plexkr_extralight_src" | head -n 1`
input_plexkr_light=`find $fonts_directories -follow -iname "$plexkr_light_src" | head -n 1`
input_plexkr_regular=`find $fonts_directories -follow -iname "$plexkr_regular_src" | head -n 1`
input_plexkr_text=`find $fonts_directories -follow -iname "$plexkr_text_src"    | head -n 1`
input_plexkr_medium=`find $fonts_directories -follow -iname "$plexkr_medium_src"    | head -n 1`
input_plexkr_semibold=`find $fonts_directories -follow -iname "$plexkr_semibold_src"    | head -n 1`
input_plexkr_bold=`find $fonts_directories -follow -iname "$plexkr_bold_src"    | head -n 1`
if [ -z "${input_plexkr_regular}" -o -z "${input_plexkr_bold}" ]
then
  echo "Error: $plexkr_regular_src and/or $plexkr_bold_src not found" >&2
  exit 1
fi

# Check filename
[ "$(basename $input_plexmono_regular)" != "$plexmono_regular_src" ] &&
  echo "Warning: ${input_plexmono_regular} does not seem to be IBMPlexMono Regular" >&2
[ "$(basename $input_plexmono_bold)" != "$plexmono_bold_src" ] &&
  echo "Warning: ${input_plexmono_regular} does not seem to be IBMPlexMono Bold" >&2
[ "$(basename $input_plexkr_regular)" != "$plexkr_regular_src" ] &&
  echo "Warning: ${input_plexkr_regular} does not seem to be IBMPlexSansKR Regular" >&2
[ "$(basename $input_plexkr_bold)" != "$plexkr_bold_src" ] &&
  echo "Warning: ${input_plexkr_bold} does not seem to be IBMPlexSansKR Bold" >&2

# Check fontforge existance
if ! which $fontforge_command > /dev/null 2>&1
then
  echo "Error: ${fontforge_command} command not found" >&2
  exit 1
fi

# Make temporary directory
if [ -w "/tmp" -a "${leaving_tmp_flag}" = "false" ]
then
  tmpdir=`mktemp -d /tmp/monoplex_kr_generator_tmpdir.XXXXXX` || exit 2
else
  tmpdir=`mktemp -d ./monoplex_kr_generator_tmpdir.XXXXXX`    || exit 2
fi

# Remove temporary directory by trapping
if [ "${leaving_tmp_flag}" = "false" ]
then
  trap "if [ -d \"$tmpdir\" ]; then echo 'Remove temporary files'; rm -rf $tmpdir; echo 'Abnormally terminated'; fi; exit 3" HUP INT QUIT
  trap "if [ -d \"$tmpdir\" ]; then echo 'Remove temporary files'; rm -rf $tmpdir; echo 'Abnormally terminated'; fi" EXIT
else
  trap "echo 'Abnormally terminated'; exit 3" HUP INT QUIT
fi

input_ideographic_space=`find $fonts_directories -follow -iname "Ideographic_Space.sfd" | head -n 1`
input_box_drawing=`find $fonts_directories -follow -iname "Box_Drawing_half.sfd" | head -n 1`

# IBM Plex Sans KR 等幅化対策 (全角左寄せの除外)
set_full_left_fewer="
  SelectFewer(8217)
  SelectFewer(8218)
  SelectFewer(8221)
  SelectFewer(8222)
"

# IBM Plex Sans KR 等幅化対策 (Widthを全角にしてからセンタリング)
set_width_full_and_center="
  SelectNone()
  SelectMore(204)
  SelectMore(205)
  SelectMore(206)
  SelectMore(207)
  SelectMore(231)
  SelectMore(236)
  SelectMore(237)
  SelectMore(238)
  SelectMore(239)
  SelectMore(253)
  SelectMore(255)
  SelectMore(305)
  SelectMore(322)
  SelectMore(353)
  SelectMore(382)
  SelectMore(402)
  SelectMore(773)
  SelectMore(8209)
  SelectMore(8254)
"

# IBM Plex Sans KR 等幅化対策 (半角左寄せ対象をセンタリングから除外する)
set_half_left_fewer="
  SelectFewer(0u2500, 0u257F)
  SelectFewer(65377)
  SelectFewer(65379)
  SelectFewer(65380)
  SelectFewer(65438)
  SelectFewer(65439)
"

# IBM Plex Sans KR 等幅化対策 (半角右寄せ対象をセンタリングから除外する)
set_half_right_fewer="
  SelectFewer(65378)
"

# IBM Plex Sans KR 等幅化対策 (全角化しつつ右寄せをセンタリングから除外する)
set_half_to_full_right_fewer="
  SelectFewer(8216)
  SelectFewer(8220)
"

########################################
# Generate script for Nerd Fonts Symbols
########################################

nerdfonts_src="Blex Mono Nerd Font Complete.ttf"
modified_nerdfonts_generator="modified_nerdfonts_generator.pe"
input_nerdfonts=`find $fonts_directories -follow -iname "$nerdfonts_src" | head -n 1`
modified_nerdfonts='modified-nerdfonts.ttf'
modified_nerdfonts35='modified-nerdfonts35.ttf'

# Nerd Fonts から適用するグリフ
select_nerd_symbols="
  # Powerline
  SelectMore(0ue0a0, 0ue0a2)
  SelectMore(0ue0b0, 0ue0b3)

  # Powerline Extra
  SelectMore(0ue0a3)
  SelectMore(0ue0b4, 0ue0c8)
  SelectMore(0ue0ca)
  SelectMore(0ue0cc, 0ue0d2)
  SelectMore(0ue0d4)

  # IEC Power Symbols
  SelectMore(0u23fb, 0u23fe)
  SelectMore(0u2b58)

  # Octicons
  SelectMore(0u2665)
  SelectMore(0u26A1)
  SelectMore(0uf27c)
  SelectMore(0uf400, 0uf4a8)

  # Font Awesome Extension
  SelectMore(0ue200, 0ue2a9)

  # Weather
  SelectMore(0ue300, 0ue3e3)

  # Seti-UI + Custom
  SelectMore(0ue5fa, 0ue62e)

  # Devicons
  SelectMore(0ue700, 0ue7c5)

  # Font Awesome
  SelectMore(0uf000, 0uf2e0)

  # Font Logos (Formerly Font Linux)
  SelectMore(0uf300, 0uf31c)

  # Material Design Icons
  SelectMore(0uf500, 0ufd46)

  # オリジナル Hack の未使用領域を一括選択 (拾い漏れ防止)
  SelectMore(0ue0d5, 0ufefd)

  # Pomicons -> 商用不可のため除外
  SelectFewer(0ue000, 0ue00d)
"

cat > ${tmpdir}/${modified_nerdfonts_generator} << _EOT_
#!$fontforge_command -script

Print("Generate Nerd Fonts parts")

# Set parameters
input_nerdfonts  = "$input_nerdfonts"
output_nerdfonts = "$modified_nerdfonts"
output_nerdfonts35 = "$modified_nerdfonts35"

# Begin loop of regular and bold
# Open IBMPlexMono
Print("Open " + input_nerdfonts)
Open(input_nerdfonts)

SelectWorthOutputting()
UnlinkReference()
ScaleToEm(${em_ascent}, ${em_descent})

# NerdFonts 以外のグリフを削除
SelectNone()
$select_nerd_symbols
SelectInvert()
Clear()

# Powerline 記号の位置調整
Select(0ue0b0); SelectMore(0ue0b4); SelectMore(0ue0b8); SelectMore(0ue0bc)
Move(-20, 0)

# Save modified NerdFonts35
Print("Save " + output_nerdfonts35)
SetOS2Value("WinAscentIsOffset",       0)
SetOS2Value("WinDescentIsOffset",      0)
SetOS2Value("TypoAscentIsOffset",      0)
SetOS2Value("TypoDescentIsOffset",     0)
SetOS2Value("HHeadAscentIsOffset",     0)
SetOS2Value("HHeadDescentIsOffset",    0)
SetOS2Value("WinAscent",             ${monoplex_kr_wide_ascent})
SetOS2Value("WinDescent",            ${monoplex_kr_wide_descent})
SetOS2Value("TypoAscent",            ${em_ascent})
SetOS2Value("TypoDescent",          -${em_descent})
SetOS2Value("TypoLineGap",           ${typo_line_gap})
SetOS2Value("HHeadAscent",           ${monoplex_kr_wide_ascent})
SetOS2Value("HHeadDescent",         -${monoplex_kr_wide_descent})
SetOS2Value("HHeadLineGap",            0)
SetPanose([2, 11, 5, 3, 2, 2, 3, 2, 2, 7])
Generate("${tmpdir}/" + output_nerdfonts35, '')

# Powerline 記号の位置調整
Select(0ue0b0); SelectMore(0ue0b4); SelectMore(0ue0b8); SelectMore(0ue0bc)
Move(-3, 0)

SelectWorthOutputting()
Scale(${plexmono_shrink_x}, ${plexmono_shrink_y}, 0, 0)
SetWidth(${monoplex_kr_half_width}, 0)

# Save modified NerdFonts
Print("Save " + output_nerdfonts)
SetOS2Value("WinAscentIsOffset",       0)
SetOS2Value("WinDescentIsOffset",      0)
SetOS2Value("TypoAscentIsOffset",      0)
SetOS2Value("TypoDescentIsOffset",     0)
SetOS2Value("HHeadAscentIsOffset",     0)
SetOS2Value("HHeadDescentIsOffset",    0)
SetOS2Value("WinAscent",             ${monoplex_kr_ascent})
SetOS2Value("WinDescent",            ${monoplex_kr_descent})
SetOS2Value("TypoAscent",            ${em_ascent})
SetOS2Value("TypoDescent",          -${em_descent})
SetOS2Value("TypoLineGap",           ${typo_line_gap})
SetOS2Value("HHeadAscent",           ${monoplex_kr_ascent})
SetOS2Value("HHeadDescent",         -${monoplex_kr_descent})
SetOS2Value("HHeadLineGap",            0)
SetPanose([2, 11, 5, 9, 2, 2, 3, 2, 2, 7])
Generate("${tmpdir}/" + output_nerdfonts, '')

Quit()
_EOT_


########################################
# Generate script for modified IBMPlexMono Material
########################################

cat > ${tmpdir}/${modified_plexmono_material_generator} << _EOT_
#!$fontforge_command -script

Print("Generate modified IBMPlexMono Material")

# Set parameters
input_list  = [ \\
                "${input_plexmono_thin}", \\
                "${input_plexmono_extralight}", \\
                "${input_plexmono_light}", \\
                "${input_plexmono_regular}", \\
                "${input_plexmono_text}", \\
                "${input_plexmono_medium}", \\
                "${input_plexmono_semibold}", \\
                "${input_plexmono_bold}", \\
                "${input_plexmono_thin_italic}", \\
                "${input_plexmono_extralight_italic}", \\
                "${input_plexmono_light_italic}", \\
                "${input_plexmono_regular_italic}", \\
                "${input_plexmono_text_italic}", \\
                "${input_plexmono_medium_italic}", \\
                "${input_plexmono_semibold_italic}", \\
                "${input_plexmono_bold_italic}" \\
              ]
r_list = [ \\
  "${input_r_thin}", \\
  "${input_r_extralight}", \\
  "${input_r_light}", \\
  "${input_r_regular}", \\
  "${input_r_text}", \\
  "${input_r_medium}", \\
  "${input_r_semibold}", \\
  "${input_r_bold}" \\
]
output_list = [ \\
                "${modified_plexmono_material_thin}", \\
                "${modified_plexmono_material_extralight}", \\
                "${modified_plexmono_material_light}", \\
                "${modified_plexmono_material_regular}", \\
                "${modified_plexmono_material_text}", \\
                "${modified_plexmono_material_medium}", \\
                "${modified_plexmono_material_semibold}", \\
                "${modified_plexmono_material_bold}", \\
                "${modified_plexmono_material_thin_italic}", \\
                "${modified_plexmono_material_extralight_italic}", \\
                "${modified_plexmono_material_light_italic}", \\
                "${modified_plexmono_material_regular_italic}", \\
                "${modified_plexmono_material_text_italic}", \\
                "${modified_plexmono_material_medium_italic}", \\
                "${modified_plexmono_material_semibold_italic}", \\
                "${modified_plexmono_material_bold_italic}" \\
              ]

if ("$DEBUG_FLG" == 'true')
  input_list = [input_list[3]]
  r_list = [r_list[3]]
  output_list = [output_list[3]]
endif

# Begin loop of regular and bold
i = 0
while (i < SizeOf(input_list))
  # Open IBMPlexMono
  Print("Open " + input_list[i])
  Open(input_list[i])

  # r グリフの調整
  if (i < SizeOf(r_list))
    Select(0u0072)
    SelectMore(0u0155)
    SelectMore(0u0157)
    SelectMore(0u0159)
    Clear()
    MergeFonts(r_list[i])
  endif

  SelectWorthOutputting()
  UnlinkReference()
  ScaleToEm(${em_ascent}, ${em_descent})

  # 半角スペースから幅を取得
  Select(0u0020)
  glyphWidth = GlyphInfo("Width")

  # クォーテーションの拡大
  Select(0u0060); Rotate(-25); Scale(100, 118); Rotate(33)
  SelectMore(0u0027)
  SelectMore(0u0060)
  Scale(109, 106); SetWidth(glyphWidth)

  # ; : , . の拡大
  Select(0u003a)
  SelectMore(0u003b)
  SelectMore(0u002c)
  SelectMore(0u002e)
  Scale(108); SetWidth(glyphWidth)

  # 罫線記号の削除（ttfautohint対策）
  Select(0u2500, 0u259f)
  Clear()

  # パスの小数点以下を切り捨て
  SelectWorthOutputting()
  RoundToInt()

  # Save modified IBMPlexMono
  Print("Save " + output_list[i])
  Save("${tmpdir}/" + output_list[i])

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for modified IBMPlexMono console
########################################

cat > ${tmpdir}/${modified_plexmono_console_generator} << _EOT_
#!$fontforge_command -script

Print("Generate modified IBMPlexMono Console")

# Set parameters
input_list  = [ \\
                "${tmpdir}/${modified_plexmono_material_thin}", \\
                "${tmpdir}/${modified_plexmono_material_extralight}", \\
                "${tmpdir}/${modified_plexmono_material_light}", \\
                "${tmpdir}/${modified_plexmono_material_regular}", \\
                "${tmpdir}/${modified_plexmono_material_text}", \\
                "${tmpdir}/${modified_plexmono_material_medium}", \\
                "${tmpdir}/${modified_plexmono_material_semibold}", \\
                "${tmpdir}/${modified_plexmono_material_bold}", \\
                "${tmpdir}/${modified_plexmono_material_thin_italic}", \\
                "${tmpdir}/${modified_plexmono_material_extralight_italic}", \\
                "${tmpdir}/${modified_plexmono_material_light_italic}", \\
                "${tmpdir}/${modified_plexmono_material_regular_italic}", \\
                "${tmpdir}/${modified_plexmono_material_text_italic}", \\
                "${tmpdir}/${modified_plexmono_material_medium_italic}", \\
                "${tmpdir}/${modified_plexmono_material_semibold_italic}", \\
                "${tmpdir}/${modified_plexmono_material_bold_italic}" \\
              ]
output_list = [ \\
                "${modified_plexmono_console_thin}", \\
                "${modified_plexmono_console_extralight}", \\
                "${modified_plexmono_console_light}", \\
                "${modified_plexmono_console_regular}", \\
                "${modified_plexmono_console_text}", \\
                "${modified_plexmono_console_medium}", \\
                "${modified_plexmono_console_semibold}", \\
                "${modified_plexmono_console_bold}", \\
                "${modified_plexmono_console_thin_italic}", \\
                "${modified_plexmono_console_extralight_italic}", \\
                "${modified_plexmono_console_light_italic}", \\
                "${modified_plexmono_console_regular_italic}", \\
                "${modified_plexmono_console_text_italic}", \\
                "${modified_plexmono_console_medium_italic}", \\
                "${modified_plexmono_console_semibold_italic}", \\
                "${modified_plexmono_console_bold_italic}" \\
              ]

if ("$DEBUG_FLG" == 'true')
  input_list = [input_list[3]]
  output_list = [output_list[3]]
endif

# Begin loop of regular and bold
i = 0
while (i < SizeOf(input_list))
  # Open IBMPlexMono
  Print("Open " + input_list[i])
  Open(input_list[i])
  SelectWorthOutputting()
  UnlinkReference()

  Scale(${plexmono_shrink_x}, ${plexmono_shrink_y}, 0, 0)

  # 半角小文字アルファベットの高さを調整
  Select(0u0061, 0u007a)
  Scale(100, 103, 0, 0)
  SelectWorthOutputting()

  # ゼロ幅文字を幅の変更対象から除外
  ii = 0
  end_plexmono = $end_plexmono
  while (ii < end_plexmono)
    if (WorthOutputting(ii))
      Select(ii)
      glyphWidth = GlyphInfo("Width")
      if (glyphWidth == 0)
        SelectFewer(ii)
      endif
    endif
    ii++
  endloop

  # 幅の変更 (Move で文字幅も変わることに注意)
  move_pt = $(((${monoplex_kr_half_width} - ${plexmono_width} * ${plexmono_shrink_x} / 100) / 2)) # -8
  width_pt = ${monoplex_kr_half_width}
  Move(move_pt, 0)
  SetWidth(width_pt, 0)

  # パスの小数点以下を切り捨て
  SelectWorthOutputting()
  RoundToInt()

  # Save modified IBMPlexMono
  Print("Save " + output_list[i])
  Save("${tmpdir}/" + output_list[i])

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for modified IBMPlexMono35 console
########################################

cat > ${tmpdir}/${modified_plexmono35_console_generator} << _EOT_
#!$fontforge_command -script

Print("Generate modified IBMPlexMono35 Console")

# Set parameters
input_list  = [ \\
                "${tmpdir}/${modified_plexmono_material_thin}", \\
                "${tmpdir}/${modified_plexmono_material_extralight}", \\
                "${tmpdir}/${modified_plexmono_material_light}", \\
                "${tmpdir}/${modified_plexmono_material_regular}", \\
                "${tmpdir}/${modified_plexmono_material_text}", \\
                "${tmpdir}/${modified_plexmono_material_medium}", \\
                "${tmpdir}/${modified_plexmono_material_semibold}", \\
                "${tmpdir}/${modified_plexmono_material_bold}", \\
                "${tmpdir}/${modified_plexmono_material_thin_italic}", \\
                "${tmpdir}/${modified_plexmono_material_extralight_italic}", \\
                "${tmpdir}/${modified_plexmono_material_light_italic}", \\
                "${tmpdir}/${modified_plexmono_material_regular_italic}", \\
                "${tmpdir}/${modified_plexmono_material_text_italic}", \\
                "${tmpdir}/${modified_plexmono_material_medium_italic}", \\
                "${tmpdir}/${modified_plexmono_material_semibold_italic}", \\
                "${tmpdir}/${modified_plexmono_material_bold_italic}" \\
              ]
output_list = [ \\
                "${modified_plexmono35_console_thin}", \\
                "${modified_plexmono35_console_extralight}", \\
                "${modified_plexmono35_console_light}", \\
                "${modified_plexmono35_console_regular}", \\
                "${modified_plexmono35_console_text}", \\
                "${modified_plexmono35_console_medium}", \\
                "${modified_plexmono35_console_semibold}", \\
                "${modified_plexmono35_console_bold}", \\
                "${modified_plexmono35_console_thin_italic}", \\
                "${modified_plexmono35_console_extralight_italic}", \\
                "${modified_plexmono35_console_light_italic}", \\
                "${modified_plexmono35_console_regular_italic}", \\
                "${modified_plexmono35_console_text_italic}", \\
                "${modified_plexmono35_console_medium_italic}", \\
                "${modified_plexmono35_console_semibold_italic}", \\
                "${modified_plexmono35_console_bold_italic}" \\
              ]

if ("$DEBUG_FLG" == 'true')
  input_list = [input_list[3]]
  output_list = [output_list[3]]
endif

# Begin loop of regular and bold
i = 0
while (i < SizeOf(input_list))
  # Open IBMPlexMono
  Print("Open " + input_list[i])
  Open(input_list[i])
  SelectWorthOutputting()
  UnlinkReference()

  # ゼロ幅文字を幅の変更対象から除外
  ii = 0
  end_plexmono = $end_plexmono
  while (ii < end_plexmono)
    if (WorthOutputting(ii))
      Select(ii)
      glyphWidth = GlyphInfo("Width")
      if (glyphWidth == 0)
        SelectFewer(ii)
      endif
    endif
    ii++
  endloop

  # 幅の変更 (Move で文字幅も変わることに注意)
  move_pt = $(((${monoplex_kr_wide_half_width} - ${plexmono_width}) / 2)) # -8
  width_pt = ${monoplex_kr_wide_half_width}
  Move(move_pt, 0)
  SetWidth(width_pt, 0)

  # パスの小数点以下を切り捨て
  SelectWorthOutputting()
  RoundToInt()

  # Save modified IBMPlexMono
  Print("Save " + output_list[i])
  Save("${tmpdir}/" + output_list[i])

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for modified IBMPlexMono
########################################

cat > ${tmpdir}/${modified_plexmono_generator} << _EOT_
#!$fontforge_command -script

Print("Generate modified IBMPlexMono")

# Set parameters
input_list  = [ \\
                "${tmpdir}/${modified_plexmono_console_thin}", \\
                "${tmpdir}/${modified_plexmono_console_extralight}", \\
                "${tmpdir}/${modified_plexmono_console_light}", \\
                "${tmpdir}/${modified_plexmono_console_regular}", \\
                "${tmpdir}/${modified_plexmono_console_text}", \\
                "${tmpdir}/${modified_plexmono_console_medium}", \\
                "${tmpdir}/${modified_plexmono_console_semibold}", \\
                "${tmpdir}/${modified_plexmono_console_bold}", \\
                "${tmpdir}/${modified_plexmono_console_thin_italic}", \\
                "${tmpdir}/${modified_plexmono_console_extralight_italic}", \\
                "${tmpdir}/${modified_plexmono_console_light_italic}", \\
                "${tmpdir}/${modified_plexmono_console_regular_italic}", \\
                "${tmpdir}/${modified_plexmono_console_text_italic}", \\
                "${tmpdir}/${modified_plexmono_console_medium_italic}", \\
                "${tmpdir}/${modified_plexmono_console_semibold_italic}", \\
                "${tmpdir}/${modified_plexmono_console_bold_italic}" \\
              ]
output_list = [ \\
                "${modified_plexmono_thin}", \\
                "${modified_plexmono_extralight}", \\
                "${modified_plexmono_light}", \\
                "${modified_plexmono_regular}", \\
                "${modified_plexmono_text}", \\
                "${modified_plexmono_medium}", \\
                "${modified_plexmono_semibold}", \\
                "${modified_plexmono_bold}", \\
                "${modified_plexmono_thin_italic}", \\
                "${modified_plexmono_extralight_italic}", \\
                "${modified_plexmono_light_italic}", \\
                "${modified_plexmono_regular_italic}", \\
                "${modified_plexmono_text_italic}", \\
                "${modified_plexmono_medium_italic}", \\
                "${modified_plexmono_semibold_italic}", \\
                "${modified_plexmono_bold_italic}" \\
              ]

if ("$DEBUG_FLG" == 'true')
  input_list = [input_list[3]]
  output_list = [output_list[3]]
endif

# Begin loop of regular and bold
i = 0
while (i < SizeOf(input_list))
  # Open IBMPlexMono
  Print("Open " + input_list[i])
  Open(input_list[i])

  # Save modified IBMPlexMono
  Print("Save " + output_list[i])
  Save("${tmpdir}/" + output_list[i])

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for modified IBMPlexMono35
########################################

cat > ${tmpdir}/${modified_plexmono35_generator} << _EOT_
#!$fontforge_command -script

Print("Generate modified IBMPlexMono")

# Set parameters
input_list  = [ \\
                "${tmpdir}/${modified_plexmono35_console_thin}", \\
                "${tmpdir}/${modified_plexmono35_console_extralight}", \\
                "${tmpdir}/${modified_plexmono35_console_light}", \\
                "${tmpdir}/${modified_plexmono35_console_regular}", \\
                "${tmpdir}/${modified_plexmono35_console_text}", \\
                "${tmpdir}/${modified_plexmono35_console_medium}", \\
                "${tmpdir}/${modified_plexmono35_console_semibold}", \\
                "${tmpdir}/${modified_plexmono35_console_bold}", \\
                "${tmpdir}/${modified_plexmono35_console_thin_italic}", \\
                "${tmpdir}/${modified_plexmono35_console_extralight_italic}", \\
                "${tmpdir}/${modified_plexmono35_console_light_italic}", \\
                "${tmpdir}/${modified_plexmono35_console_regular_italic}", \\
                "${tmpdir}/${modified_plexmono35_console_text_italic}", \\
                "${tmpdir}/${modified_plexmono35_console_medium_italic}", \\
                "${tmpdir}/${modified_plexmono35_console_semibold_italic}", \\
                "${tmpdir}/${modified_plexmono35_console_bold_italic}" \\
              ]
output_list = [ \\
                "${modified_plexmono35_thin}", \\
                "${modified_plexmono35_extralight}", \\
                "${modified_plexmono35_light}", \\
                "${modified_plexmono35_regular}", \\
                "${modified_plexmono35_text}", \\
                "${modified_plexmono35_medium}", \\
                "${modified_plexmono35_semibold}", \\
                "${modified_plexmono35_bold}", \\
                "${modified_plexmono35_thin_italic}", \\
                "${modified_plexmono35_extralight_italic}", \\
                "${modified_plexmono35_light_italic}", \\
                "${modified_plexmono35_regular_italic}", \\
                "${modified_plexmono35_text_italic}", \\
                "${modified_plexmono35_medium_italic}", \\
                "${modified_plexmono35_semibold_italic}", \\
                "${modified_plexmono35_bold_italic}" \\
              ]

if ("$DEBUG_FLG" == 'true')
  input_list = [input_list[3]]
  output_list = [output_list[3]]
endif

# Begin loop of regular and bold
i = 0
while (i < SizeOf(input_list))
  # Open IBMPlexMono
  Print("Open " + input_list[i])
  Open(input_list[i])

  # Save modified IBMPlexMono
  Print("Save " + output_list[i])
  Save("${tmpdir}/" + output_list[i])

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for modified IBMPlexSansKR
########################################

cat > ${tmpdir}/${modified_plexkr_generator} << _EOT_
#!$fontforge_command -script

Print("Generate modified IBMPlexSansKR")

# Set parameters
plexmono = "${tmpdir}/${modified_plexmono_regular}"
input_list  = [ \\
                "${input_plexkr_thin}", \\
                "${input_plexkr_extralight}", \\
                "${input_plexkr_light}", \\
                "${input_plexkr_regular}", \\
                "${input_plexkr_text}", \\
                "${input_plexkr_medium}", \\
                "${input_plexkr_semibold}", \\
                "${input_plexkr_bold}", \\
                "${input_plexkr_thin}", \\
                "${input_plexkr_extralight}", \\
                "${input_plexkr_light}", \\
                "${input_plexkr_regular}", \\
                "${input_plexkr_text}", \\
                "${input_plexkr_medium}", \\
                "${input_plexkr_semibold}", \\
                "${input_plexkr_bold}" \\
              ]
output_list = [ \\
                "${modified_plexkr_thin}", \\
                "${modified_plexkr_extralight}", \\
                "${modified_plexkr_light}", \\
                "${modified_plexkr_regular}", \\
                "${modified_plexkr_text}", \\
                "${modified_plexkr_medium}", \\
                "${modified_plexkr_semibold}", \\
                "${modified_plexkr_bold}", \\
                "${modified_plexkr_thin_italic}", \\
                "${modified_plexkr_extralight_italic}", \\
                "${modified_plexkr_light_italic}", \\
                "${modified_plexkr_regular_italic}", \\
                "${modified_plexkr_text_italic}", \\
                "${modified_plexkr_medium_italic}", \\
                "${modified_plexkr_semibold_italic}", \\
                "${modified_plexkr_bold_italic}" \\
              ]

fontstyle_list    = [ \\
                      "Thin", \\
                      "ExtraLight", \\
                      "Light", \\
                      "Regular", \\
                      "Text", \\
                      "Medium", \\
                      "SemiBold", \\
                      "Bold", \\
                      "Thin Italic", \\
                      "ExtraLight Italic", \\
                      "Light Italic", \\
                      "Regular Italic", \\
                      "Text Italic", \\
                      "Medium Italic", \\
                      "SemiBold Italic", \\
                      "Bold Italic" \\
                    ]
fontweight_list   = [ \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700, \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700 \\
                    ]
panoseweight_list = [ \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8, \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8 \\
                    ]

if ("$DEBUG_FLG" == 'true')
  input_list = [input_list[3]]
  output_list = [output_list[3]]
  fontstyle_list = [fontstyle_list[3]]
  fontweight_list = [fontweight_list[3]]
  panoseweight_list = [panoseweight_list[3]]
endif

Print("Get trim target glyph from IBMPlexMono")
Open(plexmono)
i = 0
end_plexmono = $end_plexmono
plexmono_exist_glyph_array = Array(end_plexmono)
while (i < end_plexmono)
  if (i % 5000 == 0 && "$PROGRESS_FLG" == 'true')
    Print("Processing progress: " + i)
  endif
  if (WorthOutputting(i))
    plexmono_exist_glyph_array[i] = 1
  else
    plexmono_exist_glyph_array[i] = 0
  endif
  i++
endloop
Close()

# Begin loop
i = 0
end_plexkr = $end_plexkr
i_halfwidth = 0
i_width1000 = 0
halfwidth_array = Array(10000)
width1000_array = Array(10000)
Print("Half width check loop start")
Open(input_list[0])
while (i < end_plexkr)
      if ( i % 10000 == 0 && "$PROGRESS_FLG" == 'true' )
        Print("Processing progress: " + i)
      endif
      if (WorthOutputting(i) && (i > end_plexmono || plexmono_exist_glyph_array[i] == 0))
        Select(i)
        glyphWidth = GlyphInfo("Width")
        if (glyphWidth > 0)
          if (glyphWidth < ${monoplex_kr_half_width})
            halfwidth_array[i_halfwidth] = i
            i_halfwidth = i_halfwidth + 1
          elseif (glyphWidth == 1000)
            width1000_array[i_width1000] = i
            i_width1000 = i_width1000 + 1
          endif
        endif
      endif
      i = i + 1
endloop
Close()
Print("Half width check loop end")

i = 0
while (i < SizeOf(input_list))
  # Open IBMPlexSansKR
  Print("Open " + input_list[i])
  Open(input_list[i])

  # Edit zenkaku space (from ballot box and heavy greek cross)
  if ("${HIDDEN_SPACE_FLG}" != "true")
    Select(0u3000); Clear()
    MergeFonts("$input_ideographic_space")
  endif

  SelectWorthOutputting()
  UnlinkReference()
  ScaleToEm(${em_ascent}, ${em_descent})

  # 斜体の生成
  if (Strstr(fontstyle_list[i], 'Italic') >= 0)
    Print('Generate ' + fontstyle_list[i] + ' of IBMPlexSansKR')
    Italic(${italic_angle})
  endif

  SelectNone()

  Print("Remove IBMPlexMono Glyphs start")
  ii = 0
  while ( ii < end_plexmono )
      if ( ii % 5000 == 0  && "$PROGRESS_FLG" == 'true' )
        Print("Processing progress: " + ii)
      endif
      if (WorthOutputting(ii) && plexmono_exist_glyph_array[ii] == 1)
        SelectMore(ii)
      endif
      ii = ii + 1
  endloop
  Clear()
  Print("Remove IBMPlexMono Glyphs end")

  Print("Full SetWidth start")
  move_pt = $(((${monoplex_kr_full_width} - ${plexkr_width}) / 2)) # 26
  width_pt = ${monoplex_kr_full_width} # 1076

  SelectNone()
  ii=0
  while (ii < i_width1000)
      if (InFont(width1000_array[ii]))
          SelectMore(width1000_array[ii])
      endif
      ii = ii + 1
  endloop
  Move(move_pt, 0)
  SetWidth(width_pt)

  SelectWorthOutputting()
  ii=0
  while (ii < i_halfwidth)
      if (InFont(halfwidth_array[ii]))
          SelectFewer(halfwidth_array[ii])
      endif
      ii = ii + 1
  endloop
  ii=0
  while (ii < i_width1000)
      if (InFont(width1000_array[ii]))
          SelectFewer(width1000_array[ii])
      endif
      ii = ii + 1
  endloop
  $set_full_left_fewer
  SetWidth(width_pt)
  CenterInWidth()
  Print("Full SetWidth end")

  SelectNone()

  Print("Half SetWidth start")
  move_pt = $(((${monoplex_kr_half_width} - ${plexkr_width} / 2) / 2)) # 13
  width_pt = ${monoplex_kr_half_width} # 358
  ii=0
  while (ii < i_halfwidth)
      if (InFont(halfwidth_array[ii]))
          SelectMore(halfwidth_array[ii])
      endif
      ii = ii + 1
  endloop
  $set_half_left_fewer
  $set_half_right_fewer
  $set_half_to_full_right_fewer
  SetWidth(width_pt)
  CenterInWidth()

  Print("Half SetWidth end")

  $set_width_full_and_center
  SetWidth($monoplex_kr_full_width)
  CenterInWidth()
  # IBM Plex Sans KR 等幅化対策 (半角左寄せ)
  half_left_list = [65377, 65379, 65380, 65438, 65439]
  ii = 0
  while (ii < SizeOf(half_left_list))
    Select(half_left_list[ii])
    SetWidth(${plexkr_width} / 2)
    move_pt = (${monoplex_kr_half_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_half_width})
    ii = ii + 1
  endloop
  # IBM Plex Sans KR 等幅化対策 (全角左寄せ)
  full_left_list = [8217 ,8218 ,8221 ,8222]
  ii = 0
  while (ii < SizeOf(full_left_list))
    Select(full_left_list[ii])
    SetWidth(${plexkr_width})
    move_pt = (${monoplex_kr_full_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_full_width})
    ii = ii + 1
  endloop
  # IBM Plex Sans KR 等幅化対策 (半角右寄せ)
  full_right_list = [65378]
  ii = 0
  while (ii < SizeOf(full_right_list))
    Select(full_right_list[ii])
    move_pt = (${plexkr_width} / 2) - GlyphInfo('Width')
    Move(move_pt, 0)
    SetWidth(${plexkr_width} / 2)
    move_pt = (${monoplex_kr_half_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_half_width})
    ii = ii + 1
  endloop
  # IBM Plex Sans KR 等幅化対策 (全角化して右寄せ)
  half_to_full_right_list = [8216, 8220]
  ii = 0
  while (ii < SizeOf(half_to_full_right_list))
    Select(half_to_full_right_list[ii])
    move_pt = ${plexkr_width} - GlyphInfo('Width')
    Move(move_pt, 0)
    SetWidth(${plexkr_width})
    move_pt = (${monoplex_kr_full_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_full_width})
    ii = ii + 1
  endloop

  # broken bar は IBMPlexMono ベースにする
  Select(0u00a6); Clear()

  # Edit zenkaku brackets
  Print("Edit zenkaku brackets")
  bracket_move = $((${monoplex_kr_half_width} / 2 + ${monoplex_kr_half_width} / 30))
  Select(0uff08); Move(-bracket_move, 0); SetWidth(${monoplex_kr_full_width}) # (
  Select(0uff09); Move( bracket_move, 0); SetWidth(${monoplex_kr_full_width}) # )
  Select(0uff3b); Move(-bracket_move, 0); SetWidth(${monoplex_kr_full_width}) # [
  Select(0uff3d); Move( bracket_move, 0); SetWidth(${monoplex_kr_full_width}) # ]
  Select(0uff5b); Move(-bracket_move, 0); SetWidth(${monoplex_kr_full_width}) # {
  Select(0uff5d); Move( bracket_move, 0); SetWidth(${monoplex_kr_full_width}) # }

  # 全角 ，．‘’“” の調整
  Select(0uff0e);Scale(145) ; SetWidth(${monoplex_kr_full_width}) # ．
  Select(0uff0c);Scale(140) ; SetWidth(${monoplex_kr_full_width}) # ，
  Select(0u2018);Scale(125) ; SetWidth(${monoplex_kr_full_width}) # ‘
  Select(0u2019);Scale(125) ; SetWidth(${monoplex_kr_full_width}) # ’
  Select(0u201c);Scale(125) ; SetWidth(${monoplex_kr_full_width}) # “
  Select(0u201d);Scale(125) ; SetWidth(${monoplex_kr_full_width}) # ”

  # Cent Sign, Pound Sign, Yen Sign は IBM Plex Sans KR を使用
  Select(0u00A2)
  SelectMore(0u00A3)
  SelectMore(0u00A5)
  Scale(83, 100);
  SetWidth(${monoplex_kr_half_width})
  CenterInWidth();

  # 罫線を半角化
  Select(0u2500, 0u259F)
  Clear()
  MergeFonts("$input_box_drawing")
  Select(0u2500, 0u259F)
  Move(0, 100)
  Scale(${plexmono_shrink_x}, ${plexmono_shrink_y}, 0, 0)
  foreach
    if (WorthOutputting())
      SetWidth(${monoplex_kr_half_width})
    endif
  endloop

  # 結合分音記号は IBM Plex Mono を使用する
  Select(0u0300, 0u0328)
  Clear()

  # カーニング情報を削除
  lookups = GetLookups("GPOS"); numlookups = SizeOf(lookups); ii = 0;
  while (ii < numlookups)
    if (Strstr(lookups[ii], 'halt') >= 0 \\
        || Strstr(lookups[ii], 'vhal') >= 0 \\
        || Strstr(lookups[ii], 'palt') >= 0 \\
        || Strstr(lookups[ii], 'vpal') >= 0 \\
        || Strstr(lookups[ii], 'kern') >= 0 \\
      )
      RemoveLookup(lookups[ii]);
    endif
    ii++
  endloop

  # Save modified IBMPlexSansKR
  Print("Save " + output_list[i])
  Save("${tmpdir}/" + output_list[i])
  Close()

  # Open new file
  Print("Generate IBMPlexSansKR ttf")
  New()
  # Set encoding to Unicode-bmp
  Reencode("unicode")
  # Set configuration
  if (Strstr(fontstyle_list[i], 'Italic') >= 0)
    style_split = StrSplit(fontstyle_list[i], ' ')
    SetFontNames("modified-plexkr" + style_split[0] + style_split[1])
  else
    SetFontNames("modified-plexkr" + fontstyle_list[i])
  endif
  ScaleToEm(${em_ascent}, ${em_descent})
  SetOS2Value("Weight", fontweight_list[i]) # Book or Bold
  SetOS2Value("Width",                   5) # Medium
  SetOS2Value("FSType",                  0)
  SetOS2Value("VendorID",           "PfEd")
  SetOS2Value("IBMFamily",            2057) # SS Typewriter Gothic
  SetOS2Value("WinAscentIsOffset",       0)
  SetOS2Value("WinDescentIsOffset",      0)
  SetOS2Value("TypoAscentIsOffset",      0)
  SetOS2Value("TypoDescentIsOffset",     0)
  SetOS2Value("HHeadAscentIsOffset",     0)
  SetOS2Value("HHeadDescentIsOffset",    0)
  SetOS2Value("WinAscent",             ${monoplex_kr_ascent})
  SetOS2Value("WinDescent",            ${monoplex_kr_descent})
  SetOS2Value("TypoAscent",            ${em_ascent})
  SetOS2Value("TypoDescent",          -${em_descent})
  SetOS2Value("TypoLineGap",           ${typo_line_gap})
  SetOS2Value("HHeadAscent",           ${monoplex_kr_ascent})
  SetOS2Value("HHeadDescent",         -${monoplex_kr_descent})
  SetOS2Value("HHeadLineGap",            0)
  SetPanose([2, 11, panoseweight_list[i], 9, 2, 2, 3, 2, 2, 7])

  MergeFonts("${tmpdir}/" + output_list[i])
  Generate("${tmpdir}/" + output_list[i] + ".ttf", "")
  Close()

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for modified IBMPlexSansKR for Monoplex KR Wide
########################################

cat > ${tmpdir}/${modified_plexkr_wide_generator} << _EOT_
#!$fontforge_command -script

Print("Generate modified IBMPlexSansKR - 35")

# Set parameters
plexmono = "${tmpdir}/${modified_plexmono35_regular}"
input_list  = [ \\
                "${input_plexkr_thin}", \\
                "${input_plexkr_extralight}", \\
                "${input_plexkr_light}", \\
                "${input_plexkr_regular}", \\
                "${input_plexkr_text}", \\
                "${input_plexkr_medium}", \\
                "${input_plexkr_semibold}", \\
                "${input_plexkr_bold}", \\
                "${input_plexkr_thin}", \\
                "${input_plexkr_extralight}", \\
                "${input_plexkr_light}", \\
                "${input_plexkr_regular}", \\
                "${input_plexkr_text}", \\
                "${input_plexkr_medium}", \\
                "${input_plexkr_semibold}", \\
                "${input_plexkr_bold}" \\
              ]
output_list = [ \\
                "${modified_plexkr_wide_thin}", \\
                "${modified_plexkr_wide_extralight}", \\
                "${modified_plexkr_wide_light}", \\
                "${modified_plexkr_wide_regular}", \\
                "${modified_plexkr_wide_text}", \\
                "${modified_plexkr_wide_medium}", \\
                "${modified_plexkr_wide_semibold}", \\
                "${modified_plexkr_wide_bold}", \\
                "${modified_plexkr_wide_thin_italic}", \\
                "${modified_plexkr_wide_extralight_italic}", \\
                "${modified_plexkr_wide_light_italic}", \\
                "${modified_plexkr_wide_regular_italic}", \\
                "${modified_plexkr_wide_text_italic}", \\
                "${modified_plexkr_wide_medium_italic}", \\
                "${modified_plexkr_wide_semibold_italic}", \\
                "${modified_plexkr_wide_bold_italic}" \\
              ]

fontstyle_list    = [ \\
                      "Thin", \\
                      "ExtraLight", \\
                      "Light", \\
                      "Regular", \\
                      "Text", \\
                      "Medium", \\
                      "SemiBold", \\
                      "Bold", \\
                      "Thin Italic", \\
                      "ExtraLight Italic", \\
                      "Light Italic", \\
                      "Regular Italic", \\
                      "Text Italic", \\
                      "Medium Italic", \\
                      "SemiBold Italic", \\
                      "Bold Italic" \\
                    ]

fontweight_list   = [ \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700, \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700 \\
                    ]
panoseweight_list = [ \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8, \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8 \\
                    ]

if ("$DEBUG_FLG" == 'true')
  input_list = [input_list[3]]
  output_list = [output_list[3]]
  fontstyle_list = [fontstyle_list[3]]
  fontweight_list = [fontweight_list[3]]
  panoseweight_list = [panoseweight_list[3]]
endif

Print("Get trim target glyph from IBMPlexMono")
Open(plexmono)
i = 0
end_plexmono = $end_plexmono
plexmono_exist_glyph_array = Array(end_plexmono)
while (i < end_plexmono)
  if (i % 5000 == 0 && "$PROGRESS_FLG" == 'true')
    Print("Processing progress: " + i)
  endif
  if (WorthOutputting(i))
    plexmono_exist_glyph_array[i] = 1
  else
    plexmono_exist_glyph_array[i] = 0
  endif
  i++
endloop
Close()

# Begin loop
i = 0
end_plexkr = $end_plexkr
i_halfwidth = 0
i_width1000 = 0
halfwidth_array = Array(10000)
width1000_array = Array(10000)
Print("Half width check loop start")
Open(input_list[0])
while (i < end_plexkr)
      if ( i % 10000 == 0 && "$PROGRESS_FLG" == 'true' )
        Print("Processing progress: " + i)
      endif
      if (WorthOutputting(i) && (i > end_plexmono || plexmono_exist_glyph_array[i] == 0))
        Select(i)
        glyphWidth = GlyphInfo("Width")
        if (glyphWidth > 0)
          if (glyphWidth < ${monoplex_kr_half_width})
            halfwidth_array[i_halfwidth] = i
            i_halfwidth = i_halfwidth + 1
          elseif (glyphWidth == 1000)
            width1000_array[i_width1000] = i
            i_width1000 = i_width1000 + 1
          endif
        endif
      endif
      i = i + 1
endloop
Close()
Print("Half width check loop end")

i = 0
while (i < SizeOf(input_list))
  # Open IBMPlexSansKR
  Print("Open " + input_list[i])
  Open(input_list[i])

  # Edit zenkaku space (from ballot box and heavy greek cross)
  if ("${HIDDEN_SPACE_FLG}" != "true")
    Select(0u3000); Clear()
    MergeFonts("$input_ideographic_space")
  endif

  SelectWorthOutputting()
  UnlinkReference()
  ScaleToEm(${em_ascent}, ${em_descent})

  # 斜体の生成
  if (Strstr(fontstyle_list[i], 'Italic') >= 0)
    Print('Generate ' + fontstyle_list[i] + ' of IBMPlexSansKR')
    Italic(${italic_angle})
  endif

  SelectNone()

  Print("Remove IBMPlexMono Glyphs start")
  ii = 0
  while ( ii < end_plexmono )
      if ( ii % 5000 == 0  && "$PROGRESS_FLG" == 'true')
        Print("Processing progress: " + ii)
      endif
      if (WorthOutputting(ii) && plexmono_exist_glyph_array[ii] == 1)
        SelectMore(ii)
      endif
      ii = ii + 1
  endloop
  Clear()
  Print("Remove IBMPlexMono Glyphs end")

  Print("Full SetWidth start")
  move_pt = $(((${monoplex_kr_wide_full_width} - ${plexkr_width}) / 2)) # 3
  width_pt = ${monoplex_kr_wide_full_width} # 1030

  SelectNone()
  ii=0
  while (ii < i_width1000)
      if (InFont(width1000_array[ii]))
          SelectMore(width1000_array[ii])
      endif
      ii = ii + 1
  endloop
  Move(move_pt, 0)
  SetWidth(width_pt)

  SelectWorthOutputting()
  ii=0
  while (ii < i_halfwidth)
      if (InFont(halfwidth_array[ii]))
          SelectFewer(halfwidth_array[ii])
      endif
      ii = ii + 1
  endloop
  ii=0
  while (ii < i_width1000)
      if (InFont(width1000_array[ii]))
          SelectFewer(width1000_array[ii])
      endif
      ii = ii + 1
  endloop
  $set_full_left_fewer
  SetWidth(width_pt)
  CenterInWidth()
  Print("Full SetWidth end")

  Print("Half SetWidth start")
  move_pt = $(((${monoplex_kr_wide_half_width} - ${plexkr_width} / 2) / 2)) # 35
  width_pt = ${monoplex_kr_wide_half_width} # 618
  ii=0
  while (ii < i_halfwidth)
      if (InFont(halfwidth_array[ii]))
          SelectMore(halfwidth_array[ii])
      endif
      ii = ii + 1
  endloop
  $set_half_left_fewer
  $set_half_right_fewer
  $set_half_to_full_right_fewer
  SetWidth(width_pt)
  CenterInWidth()

  Print("Half SetWidth end")

  $set_width_full_and_center
  SetWidth($monoplex_kr_wide_full_width)
  CenterInWidth()
  # IBM Plex Sans KR 等幅化対策 (半角左寄せ)
  half_left_list = [65377, 65379, 65380, 65438, 65439]
  ii = 0
  while (ii < SizeOf(half_left_list))
    Select(half_left_list[ii])
    SetWidth(${plexkr_width} / 2)
    move_pt = (${monoplex_kr_wide_half_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_wide_half_width})
    ii = ii + 1
  endloop
  # IBM Plex Sans KR 等幅化対策 (全角左寄せ)
  full_left_list = [8217 ,8218 ,8221 ,8222]
  ii = 0
  while (ii < SizeOf(full_left_list))
    Select(full_left_list[ii])
    SetWidth(${plexkr_width})
    move_pt = (${monoplex_kr_wide_full_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_wide_full_width})
    ii = ii + 1
  endloop
  # IBM Plex Sans KR 等幅化対策 (半角右寄せ)
  full_right_list = [65378]
  ii = 0
  while (ii < SizeOf(full_right_list))
    Select(full_right_list[ii])
    move_pt = (${plexkr_width} / 2) - GlyphInfo('Width')
    Move(move_pt, 0)
    SetWidth(${plexkr_width} / 2)
    move_pt = (${monoplex_kr_wide_half_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_wide_half_width})
    ii = ii + 1
  endloop
  # IBM Plex Sans KR 等幅化対策 (全角化して右寄せ)
  half_to_full_right_list = [8216, 8220]
  ii = 0
  while (ii < SizeOf(half_to_full_right_list))
    Select(half_to_full_right_list[ii])
    move_pt = ${plexkr_width} - GlyphInfo('Width')
    Move(move_pt, 0)
    SetWidth(${plexkr_width})
    move_pt = (${monoplex_kr_wide_full_width} - GlyphInfo('Width')) / 2
    Move(move_pt, 0)
    SetWidth(${monoplex_kr_wide_full_width})
    ii = ii + 1
  endloop

  # broken bar は IBMPlexMono ベースにする
  Select(0u00a6); Clear()

  # Edit zenkaku brackets
  Print("Edit zenkaku brackets")
  bracket_move = $((${monoplex_kr_wide_half_width} / 2 + ${monoplex_kr_wide_half_width} / 30))
  Select(0uff08); Move(-bracket_move, 0); SetWidth(${monoplex_kr_wide_full_width}) # (
  Select(0uff09); Move( bracket_move, 0); SetWidth(${monoplex_kr_wide_full_width}) # )
  Select(0uff3b); Move(-bracket_move, 0); SetWidth(${monoplex_kr_wide_full_width}) # [
  Select(0uff3d); Move( bracket_move, 0); SetWidth(${monoplex_kr_wide_full_width}) # ]
  Select(0uff5b); Move(-bracket_move, 0); SetWidth(${monoplex_kr_wide_full_width}) # {
  Select(0uff5d); Move( bracket_move, 0); SetWidth(${monoplex_kr_wide_full_width}) # }

  # 全角 ，．‘’“” の調整
  Select(0uff0e);Scale(145) ; SetWidth(${monoplex_kr_wide_full_width}) # ．
  Select(0uff0c);Scale(140) ; SetWidth(${monoplex_kr_wide_full_width}) # ，
  Select(0u2018);Scale(125) ; SetWidth(${monoplex_kr_wide_full_width}) # ‘
  Select(0u2019);Scale(125) ; SetWidth(${monoplex_kr_wide_full_width}) # ’
  Select(0u201c);Scale(125) ; SetWidth(${monoplex_kr_wide_full_width}) # “
  Select(0u201d);Scale(125) ; SetWidth(${monoplex_kr_wide_full_width}) # ”

  # Cent Sign, Pound Sign, Yen Sign は IBM Plex Sans KR を使用
  Select(0u00A2)
  SelectMore(0u00A3)
  SelectMore(0u00A5)
  Scale(94, 100)
  SetWidth(${monoplex_kr_wide_half_width})
  CenterInWidth()

  # 罫線を半角化
  Select(0u2500, 0u259F)
  Clear()
  MergeFonts("$input_box_drawing")
  Select(0u2500, 0u259F)
  Move(0, 100)

  # 結合分音記号は IBM Plex Mono を使用する
  Select(0u0300, 0u0328)
  Clear()


  # カーニング情報を削除
  lookups = GetLookups("GPOS"); numlookups = SizeOf(lookups); ii = 0;
  while (ii < numlookups)
    if (Strstr(lookups[ii], 'halt') >= 0 \\
        || Strstr(lookups[ii], 'vhal') >= 0 \\
        || Strstr(lookups[ii], 'palt') >= 0 \\
        || Strstr(lookups[ii], 'vpal') >= 0 \\
        || Strstr(lookups[ii], 'kern') >= 0 \\
      )
      RemoveLookup(lookups[ii]);
    endif
    ii++
  endloop

  # Save modified IBMPlexSansKR
  Print("Save " + output_list[i])
  Save("${tmpdir}/" + output_list[i])
  Close()

  # Open new file
  Print("Generate IBMPlexSansKR ttf")
  New()
  # Set encoding to Unicode-bmp
  Reencode("unicode")
  # Set configuration
  if (Strstr(fontstyle_list[i], 'Italic') >= 0)
    style_split = StrSplit(fontstyle_list[i], ' ')
    SetFontNames("modified-plexkr" + style_split[0] + style_split[1])
  else
    SetFontNames("modified-plexkr" + fontstyle_list[i])
  endif
  ScaleToEm(${em_ascent}, ${em_descent})
  SetOS2Value("Weight", fontweight_list[i]) # Book or Bold
  SetOS2Value("Width",                   5) # Medium
  SetOS2Value("FSType",                  0)
  SetOS2Value("VendorID",           "PfEd")
  SetOS2Value("IBMFamily",            2057) # SS Typewriter Gothic
  SetOS2Value("WinAscentIsOffset",       0)
  SetOS2Value("WinDescentIsOffset",      0)
  SetOS2Value("TypoAscentIsOffset",      0)
  SetOS2Value("TypoDescentIsOffset",     0)
  SetOS2Value("HHeadAscentIsOffset",     0)
  SetOS2Value("HHeadDescentIsOffset",    0)
  SetOS2Value("WinAscent",             ${monoplex_kr_wide_ascent})
  SetOS2Value("WinDescent",            ${monoplex_kr_wide_descent})
  SetOS2Value("TypoAscent",            ${em_ascent})
  SetOS2Value("TypoDescent",          -${em_descent})
  SetOS2Value("TypoLineGap",           ${typo_line_gap})
  SetOS2Value("HHeadAscent",           ${monoplex_kr_wide_ascent})
  SetOS2Value("HHeadDescent",         -${monoplex_kr_wide_descent})
  SetOS2Value("HHeadLineGap",            0)
  SetPanose([2, 11, panoseweight_list[i], 3, 2, 2, 3, 2, 2, 7])

  MergeFonts("${tmpdir}/" + output_list[i])
  Generate("${tmpdir}/" + output_list[i] + ".ttf", "")
  Close()

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for Monoplex KR
########################################

cat > ${tmpdir}/${monoplex_kr_generator} << _EOT_
#!$fontforge_command -script

# Print message
Print("Generate Monoplex KR")

# Set parameters
plexmono_list  = [ \\
                    "${tmpdir}/${modified_plexmono_thin}", \\
                    "${tmpdir}/${modified_plexmono_extralight}", \\
                    "${tmpdir}/${modified_plexmono_light}", \\
                    "${tmpdir}/${modified_plexmono_regular}", \\
                    "${tmpdir}/${modified_plexmono_text}", \\
                    "${tmpdir}/${modified_plexmono_medium}", \\
                    "${tmpdir}/${modified_plexmono_semibold}", \\
                    "${tmpdir}/${modified_plexmono_bold}", \\
                    "${tmpdir}/${modified_plexmono_thin_italic}", \\
                    "${tmpdir}/${modified_plexmono_extralight_italic}", \\
                    "${tmpdir}/${modified_plexmono_light_italic}", \\
                    "${tmpdir}/${modified_plexmono_regular_italic}", \\
                    "${tmpdir}/${modified_plexmono_text_italic}", \\
                    "${tmpdir}/${modified_plexmono_medium_italic}", \\
                    "${tmpdir}/${modified_plexmono_semibold_italic}", \\
                    "${tmpdir}/${modified_plexmono_bold_italic}" \\
                  ]
fontfamily        = "${monoplex_kr_familyname}"
fontfamily_sht    = "$(echo ${monoplex_kr_familyname} | tr -d '[:space:]')"
fontfamilysuffix  = "${monoplex_kr_familyname_suffix}"

fontstyle_list    = [ \\
                      "Thin", \\
                      "ExtraLight", \\
                      "Light", \\
                      "Regular", \\
                      "Text", \\
                      "Medium", \\
                      "SemiBold", \\
                      "Bold", \\
                      "Thin Italic", \\
                      "ExtraLight Italic", \\
                      "Light Italic", \\
                      "Regular Italic", \\
                      "Text Italic", \\
                      "Medium Italic", \\
                      "SemiBold Italic", \\
                      "Bold Italic" \\
                    ]

fontweight_list   = [ \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700, \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700 \\
                    ]
panoseweight_list = [ \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8, \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8 \\
                    ]

if ("$DEBUG_FLG" == 'true')
  plexmono_list = [plexmono_list[3]]
  fontstyle_list = [fontstyle_list[3]]
  fontweight_list = [fontweight_list[3]]
  panoseweight_list = [panoseweight_list[3]]
endif

copyright         = "Copyright (c) 2021, Kim Yangsu"
version           = "${monoplex_kr_version}"

# Begin loop of regular and bold
i = 0
while (i < SizeOf(fontstyle_list))
  # Open new file
  New()

  # Set encoding to Unicode-bmp
  Reencode("unicode")

  fontname_style = fontstyle_list[i]
  base_style = fontstyle_list[i]

  # 斜体の生成
  if (Strstr(fontstyle_list[i], 'Italic') >= 0)
    SetItalicAngle(${italic_angle})
    style_split = StrSplit(fontstyle_list[i], ' ')
    if (style_split[0] == 'Regular')
      fontname_style = 'Italic'
    else
      fontname_style = style_split[0] + style_split[1]
    endif
    base_style = style_split[0]
  endif

  # Set configuration
  if (Strstr(fontstyle_list[i], 'Regular') == -1 && Strstr(fontstyle_list[i], 'Bold') == -1)
    if (fontfamilysuffix != "")
      SetFontNames(fontfamily_sht + fontfamilysuffix + "-" + fontname_style, \\
                    fontfamily + " " + fontfamilysuffix + " " + base_style, \\
                    fontfamily + " " + fontfamilysuffix + " " + fontstyle_list[i], \\
                    base_style, \\
                    copyright, version)
    else
      SetFontNames(fontfamily_sht + "-" + fontname_style, \\
                    fontfamily + " " + base_style, \\
                    fontfamily + " " + fontstyle_list[i], \\
                    base_style, \\
                    copyright, version)
    endif

    if (Strstr(fontstyle_list[i], 'Italic') >= 0)
      SetTTFName(0x409, 2, "Italic")
    else
      SetTTFName(0x409, 2, "Regular")
    endif
  else
    display_style = fontstyle_list[i]
    if (fontstyle_list[i] == 'Regular Italic')
      SetTTFName(0x409, 2, 'Italic')
      display_style = 'Italic'
    else
      SetTTFName(0x409, 2, fontstyle_list[i])
    endif

    if (fontfamilysuffix != "")
      SetFontNames(fontfamily_sht + fontfamilysuffix + "-" + fontname_style, \\
                    fontfamily + " " + fontfamilysuffix, \\
                    fontfamily + " " + fontfamilysuffix + " " + display_style, \\
                    base_style, \\
                    copyright, version)
    else
      SetFontNames(fontfamily_sht + "-" + fontname_style, \\
                    fontfamily, \\
                    fontfamily + " " + display_style, \\
                    base_style, \\
                    copyright, version)
    endif
  endif

  if (fontfamilysuffix != "")
    SetTTFName(0x409, 16, fontfamily + " " + fontfamilysuffix)
  else
    SetTTFName(0x409, 16, fontfamily)
  endif
  if (fontstyle_list[i] == 'Regular Italic')
    SetTTFName(0x409, 17, 'Italic')
  else
    SetTTFName(0x409, 17, fontstyle_list[i])
  endif


  SetTTFName(0x409, 3, "FontForge 2.0 : " + \$fullname + " : " + Strftime("%d-%m-%Y", 0))

  ScaleToEm(${em_ascent}, ${em_descent})
  SetOS2Value("Weight", fontweight_list[i]) # Book or Bold
  SetOS2Value("Width",                   5) # Medium
  SetOS2Value("FSType",                  0)
  SetOS2Value("VendorID",           "PfEd")
  SetOS2Value("IBMFamily",            2057) # SS Typewriter Gothic
  SetOS2Value("WinAscentIsOffset",       0)
  SetOS2Value("WinDescentIsOffset",      0)
  SetOS2Value("TypoAscentIsOffset",      0)
  SetOS2Value("TypoDescentIsOffset",     0)
  SetOS2Value("HHeadAscentIsOffset",     0)
  SetOS2Value("HHeadDescentIsOffset",    0)
  SetOS2Value("WinAscent",             ${monoplex_kr_ascent})
  SetOS2Value("WinDescent",            ${monoplex_kr_descent})
  SetOS2Value("TypoAscent",            ${em_ascent})
  SetOS2Value("TypoDescent",          -${em_descent})
  SetOS2Value("TypoLineGap",           ${typo_line_gap})
  SetOS2Value("HHeadAscent",           ${monoplex_kr_ascent})
  SetOS2Value("HHeadDescent",         -${monoplex_kr_descent})
  SetOS2Value("HHeadLineGap",            0)
  SetPanose([2, 11, panoseweight_list[i], 9, 2, 2, 3, 2, 2, 7])

  # Merge IBMPlexMono font
  Print("Merge " + plexmono_list[i]:t)
  MergeFonts(plexmono_list[i])

  # Save Monoplex KR
  if (fontfamilysuffix != "")
        Print("Save " + fontfamily_sht + fontfamilysuffix + "-" + fontname_style + ".ttf")
        Generate("${base_dir}/" + fontfamily_sht + fontfamilysuffix + "-" + fontname_style + ".ttf", "")
  else
        Print("Save " + fontfamily_sht + "-" + fontname_style + ".ttf")
        Generate("${base_dir}/" + fontfamily_sht + "-" + fontname_style + ".ttf", "")
  endif
  Close()

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate script for Monoplex KR Wide
########################################

cat > ${tmpdir}/${monoplex_kr_wide_generator} << _EOT_
#!$fontforge_command -script

# Print message
Print("Generate Monoplex KR")

# Set parameters
plexmono_list  = [ \\
                    "${tmpdir}/${modified_plexmono35_thin}", \\
                    "${tmpdir}/${modified_plexmono35_extralight}", \\
                    "${tmpdir}/${modified_plexmono35_light}", \\
                    "${tmpdir}/${modified_plexmono35_regular}", \\
                    "${tmpdir}/${modified_plexmono35_text}", \\
                    "${tmpdir}/${modified_plexmono35_medium}", \\
                    "${tmpdir}/${modified_plexmono35_semibold}", \\
                    "${tmpdir}/${modified_plexmono35_bold}", \\
                    "${tmpdir}/${modified_plexmono35_thin_italic}", \\
                    "${tmpdir}/${modified_plexmono35_extralight_italic}", \\
                    "${tmpdir}/${modified_plexmono35_light_italic}", \\
                    "${tmpdir}/${modified_plexmono35_regular_italic}", \\
                    "${tmpdir}/${modified_plexmono35_text_italic}", \\
                    "${tmpdir}/${modified_plexmono35_medium_italic}", \\
                    "${tmpdir}/${modified_plexmono35_semibold_italic}", \\
                    "${tmpdir}/${modified_plexmono35_bold_italic}" \\
                  ]
fontfamily        = "${monoplex_kr_wide_familyname}"
fontfamily_sht    = "$(echo ${monoplex_kr_wide_familyname} | tr -d '[:space:]')"
fontfamilysuffix  = "${monoplex_kr_wide_familyname_suffix}"

fontstyle_list    = [ \\
                      "Thin", \\
                      "ExtraLight", \\
                      "Light", \\
                      "Regular", \\
                      "Text", \\
                      "Medium", \\
                      "SemiBold", \\
                      "Bold", \\
                      "Thin Italic", \\
                      "ExtraLight Italic", \\
                      "Light Italic", \\
                      "Regular Italic", \\
                      "Text Italic", \\
                      "Medium Italic", \\
                      "SemiBold Italic", \\
                      "Bold Italic" \\
                    ]

fontweight_list   = [ \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700, \\
                      100, \\
                      200, \\
                      300, \\
                      400, \\
                      450, \\
                      500, \\
                      600, \\
                      700 \\
                    ]
panoseweight_list = [ \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8, \\
                      3, \\
                      3, \\
                      4, \\
                      5, \\
                      5, \\
                      6, \\
                      7, \\
                      8 \\
                    ]

if ("$DEBUG_FLG" == 'true')
  plexmono_list = [plexmono_list[3]]
  fontstyle_list = [fontstyle_list[3]]
  fontweight_list = [fontweight_list[3]]
  panoseweight_list = [panoseweight_list[3]]
endif

copyright         = "Copyright (c) 2021, Kim Yangsu"
version           = "${monoplex_kr_version}"

# Begin loop of regular and bold
i = 0
while (i < SizeOf(fontstyle_list))
  # Open new file
  New()

  # Set encoding to Unicode-bmp
  Reencode("unicode")

  fontname_style = fontstyle_list[i]
  base_style = fontstyle_list[i]

  # 斜体の生成
  if (Strstr(fontstyle_list[i], 'Italic') >= 0)
    SetItalicAngle(${italic_angle})
    style_split = StrSplit(fontstyle_list[i], ' ')
    if (style_split[0] == 'Regular')
      fontname_style = 'Italic'
    else
      fontname_style = style_split[0] + style_split[1]
    endif
    base_style = style_split[0]
  endif

  # Set configuration
  if (Strstr(fontstyle_list[i], 'Regular') == -1 && Strstr(fontstyle_list[i], 'Bold') == -1)
    if (fontfamilysuffix != "")
      SetFontNames(fontfamily_sht + fontfamilysuffix + "-" + fontname_style, \\
                    fontfamily + " " + fontfamilysuffix + " " + base_style, \\
                    fontfamily + " " + fontfamilysuffix + " " + fontstyle_list[i], \\
                    base_style, \\
                    copyright, version)
    else
      SetFontNames(fontfamily_sht + "-" + fontname_style, \\
                    fontfamily + " " + base_style, \\
                    fontfamily + " " + fontstyle_list[i], \\
                    base_style, \\
                    copyright, version)
    endif

    if (Strstr(fontstyle_list[i], 'Italic') >= 0)
      SetTTFName(0x409, 2, "Italic")
    else
      SetTTFName(0x409, 2, "Regular")
    endif
  else
    display_style = fontstyle_list[i]
    if (fontstyle_list[i] == 'Regular Italic')
      SetTTFName(0x409, 2, 'Italic')
      display_style = 'Italic'
    else
      SetTTFName(0x409, 2, fontstyle_list[i])
    endif

    if (fontfamilysuffix != "")
      SetFontNames(fontfamily_sht + fontfamilysuffix + "-" + fontname_style, \\
                    fontfamily + " " + fontfamilysuffix, \\
                    fontfamily + " " + fontfamilysuffix + " " + display_style, \\
                    base_style, \\
                    copyright, version)
    else
      SetFontNames(fontfamily_sht + "-" + fontname_style, \\
                    fontfamily, \\
                    fontfamily + " " + display_style, \\
                    base_style, \\
                    copyright, version)
    endif
  endif

  if (fontfamilysuffix != "")
    SetTTFName(0x409, 16, fontfamily + " " + fontfamilysuffix)
  else
    SetTTFName(0x409, 16, fontfamily)
  endif
  if (fontstyle_list[i] == 'Regular Italic')
    SetTTFName(0x409, 17, 'Italic')
  else
    SetTTFName(0x409, 17, fontstyle_list[i])
  endif


  SetTTFName(0x409, 3, "FontForge 2.0 : " + \$fullname + " : " + Strftime("%d-%m-%Y", 0))

  ScaleToEm(${em_ascent}, ${em_descent})
  SetOS2Value("Weight", fontweight_list[i]) # Book or Bold
  SetOS2Value("Width",                   5) # Medium
  SetOS2Value("FSType",                  0)
  SetOS2Value("VendorID",           "PfEd")
  SetOS2Value("IBMFamily",            2057) # SS Typewriter Gothic
  SetOS2Value("WinAscentIsOffset",       0)
  SetOS2Value("WinDescentIsOffset",      0)
  SetOS2Value("TypoAscentIsOffset",      0)
  SetOS2Value("TypoDescentIsOffset",     0)
  SetOS2Value("HHeadAscentIsOffset",     0)
  SetOS2Value("HHeadDescentIsOffset",    0)
  SetOS2Value("WinAscent",             ${monoplex_kr_wide_ascent})
  SetOS2Value("WinDescent",            ${monoplex_kr_wide_descent})
  SetOS2Value("TypoAscent",            ${em_ascent})
  SetOS2Value("TypoDescent",          -${em_descent})
  SetOS2Value("TypoLineGap",           ${typo_line_gap})
  SetOS2Value("HHeadAscent",           ${monoplex_kr_wide_ascent})
  SetOS2Value("HHeadDescent",         -${monoplex_kr_wide_descent})
  SetOS2Value("HHeadLineGap",            0)
  SetPanose([2, 11, panoseweight_list[i], 3, 2, 2, 3, 2, 2, 7])

  # Merge IBMPlexMono font
  Print("Merge " + plexmono_list[i]:t)
  MergeFonts(plexmono_list[i])

  # Save Monoplex KR
  if (fontfamilysuffix != "")
        Print("Save " + fontfamily_sht + fontfamilysuffix + "-" + fontname_style + ".ttf")
        Generate("${base_dir}/" + fontfamily_sht + fontfamilysuffix + "-" + fontname_style + ".ttf", "")
  else
        Print("Save " + fontfamily_sht + "-" + fontname_style + ".ttf")
        Generate("${base_dir}/" + fontfamily_sht + "-" + fontname_style + ".ttf", "")
  endif
  Close()

  i += 1
endloop

Quit()
_EOT_

########################################
# Generate Monoplex KR
########################################

# Generate Nerd Fonts Symbols
if [ "$NERDFONTS_FLG" = 'true' ]; then
  $fontforge_command -script ${tmpdir}/${modified_nerdfonts_generator} 2> $redirection_stderr || exit 4
fi

# Generate Material
$fontforge_command -script ${tmpdir}/${modified_plexmono_material_generator} 2> $redirection_stderr || exit 4

# Generate Console
$fontforge_command -script ${tmpdir}/${modified_plexmono_console_generator} 2> $redirection_stderr || exit 4

# Generate Modiifed IBMPlexMono
$fontforge_command -script ${tmpdir}/${modified_plexmono_generator} 2> $redirection_stderr || exit 4

# Generate Modified IBMPlexSansKR
$fontforge_command -script ${tmpdir}/${modified_plexkr_generator} 2> $redirection_stderr || exit 4

# Generate Monoplex KR
$fontforge_command -script ${tmpdir}/${monoplex_kr_generator} 2> $redirection_stderr || exit 4

# Generate Console - 35
$fontforge_command -script ${tmpdir}/${modified_plexmono35_console_generator} 2> $redirection_stderr || exit 4

# Generate Modiifed IBMPlexMono - 35
$fontforge_command -script ${tmpdir}/${modified_plexmono35_generator} 2> $redirection_stderr || exit 4

# Generate Modified IBMPlexSansKR - 35
$fontforge_command -script ${tmpdir}/${modified_plexkr_wide_generator} 2> $redirection_stderr || exit 4

# Generate Monoplex KR - 35
$fontforge_command -script ${tmpdir}/${monoplex_kr_wide_generator} 2> $redirection_stderr || exit 4

style_list='Thin ExtraLight Light Regular Text Medium SemiBold Bold ThinItalic ExtraLightItalic LightItalic Italic TextItalic MediumItalic SemiBoldItalic BoldItalic'

if [ "$DEBUG_FLG" = 'true' ]; then
  style_list='Regular'
fi

for style in $style_list
do
  monoplex_kr_filename="$(echo "${monoplex_kr_familyname}${monoplex_kr_familyname_suffix}-${style}.ttf" | tr -d '[:space:]')"
  monoplex_kr_wide_filename="$(echo "${monoplex_kr_wide_familyname}${monoplex_kr_familyname_suffix}-${style}.ttf" | tr -d '[:space:]')"
  nerdfonts="${tmpdir}/${modified_nerdfonts}"
  nerdfonts35="${tmpdir}/${modified_nerdfonts35}"

  # Add hinting
  # Monoplex KR
  for f in "$monoplex_kr_filename"
  do
    ttfautohint -l 6 -r 45 -a nnn -D latn -W -X "15-" -I "$f" "hinted_${f}"
  done
  # Monoplex KR Wide
  for f in "$monoplex_kr_wide_filename"
  do
    m_opt=''
    post_process_file="${base_dir}/hinting_post_process/35-${style}-ctrl.txt"
    if [ -f "$post_process_file" ]; then
      m_opt="-m $post_process_file"
    fi
    ttfautohint $m_opt -l 6 -r 45 -a nnn -D latn -W -X "13-" -I "$f" "hinted_${f}"
  done

  if [ "${style}" = 'Thin' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_thin}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_thin}.ttf"
  fi
  if [ "${style}" = 'ExtraLight' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_extralight}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_extralight}.ttf"
  fi
  if [ "${style}" = 'Light' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_light}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_light}.ttf"
  fi
  if [ "${style}" = 'Regular' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_regular}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_regular}.ttf"
  fi
  if [ "${style}" = 'Text' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_text}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_text}.ttf"
  fi
  if [ "${style}" = 'Medium' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_medium}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_medium}.ttf"
  fi
  if [ "${style}" = 'SemiBold' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_semibold}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_semibold}.ttf"
  fi
  if [ "${style}" = 'Bold' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_bold}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_bold}.ttf"
  fi
  if [ "${style}" = 'ThinItalic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_thin_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_thin_italic}.ttf"
  fi
  if [ "${style}" = 'ExtraLightItalic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_extralight_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_extralight_italic}.ttf"
  fi
  if [ "${style}" = 'LightItalic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_light_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_light_italic}.ttf"
  fi
  if [ "${style}" = 'Italic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_regular_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_regular_italic}.ttf"
  fi
  if [ "${style}" = 'TextItalic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_text_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_text_italic}.ttf"
  fi
  if [ "${style}" = 'MediumItalic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_medium_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_medium_italic}.ttf"
  fi
  if [ "${style}" = 'SemiBoldItalic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_semibold_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_semibold_italic}.ttf"
  fi
  if [ "${style}" = 'BoldItalic' ]; then
    marge_plexkr_regular="${tmpdir}/${modified_plexkr_bold_italic}.ttf"
    marge_plexkr_wide_regular="${tmpdir}/${modified_plexkr_wide_bold_italic}.ttf"
  fi

  # Generate Nerd Fonts version
  if [ "$NERDFONTS_FLG" = 'true' ]; then
    # Monoplex KR Nerd
    echo "pyftmerge: ${monoplex_kr_filename}"
    pyftmerge "hinted_${monoplex_kr_filename}" "$nerdfonts"
    pyftmerge merged.ttf "$marge_plexkr_regular"
    mv merged.ttf "${monoplex_kr_filename}"

    # Monoplex KR Wide Nerd
    echo "pyftmerge: ${monoplex_kr_wide_filename}"
    pyftmerge "hinted_${monoplex_kr_wide_filename}" "$nerdfonts35"
    pyftmerge merged.ttf "$marge_plexkr_wide_regular"
    mv merged.ttf "${monoplex_kr_wide_filename}"

    continue
  fi

  # Monoplex KR
  echo "pyftmerge: ${monoplex_kr_filename}"
  pyftmerge "hinted_${monoplex_kr_filename}" "$marge_plexkr_regular"
  mv merged.ttf "${monoplex_kr_filename}"

  # Monoplex KR Wide
  echo "pyftmerge: ${monoplex_kr_wide_filename}"
  pyftmerge "hinted_${monoplex_kr_wide_filename}" "$marge_plexkr_wide_regular"
  mv merged.ttf "${monoplex_kr_wide_filename}"

done

rm -f hinted_*.ttf

# Remove temporary directory
if [ "${leaving_tmp_flag}" = "false" ]
then
  echo "Remove temporary files"
  rm -rf $tmpdir
fi

# Exit
echo "Succeeded in generating Monoplex KR!"
exit 0
