# https://github.com/alansarkar/Rofi-fuzzy-finder-Launcher-/blob/master/Rofi-FzF
#!/bin/bash


#cpulimit -P "$0" -l 25    

TEXTEDIT="alacritty -e vim"
FILEMANAGER=nautilus
VIDEO=/bin/mpv
IMAGE=/bin/feh
PDF=/bin/evince

#CPULIMIT=" cpulimit -c 3 --background  --limit 20%    --exe  "
DIR_TO_SEARCH="$HOME/documents/ $HOME/git/ $HOME/downloads /media/M.2_4TB_1 "


function rofi_main()
{

#if [ -z $CPULIMIT ] ; then 
    selected="` (echo . ; (find $DIR_TO_SEARCH   \( ! -regex '.*/\..*' \)) ) | rofi -theme $HOME/.config/rofi/text_theme_fullscreen.rasi -dmenu -i -p "Open"`" ; 
#else  selected="` $CPULIMIT  echo . ; (find /   \( ! -regex '.*/\..*' \))  | rofi  -dmenu -i -p "Open"`" ; fi 

#ext="$(echo $selected | sed 's/\s*.*\.//g' )"
if [[ "$selected" == "." ]]; 
then selected=$( find ~ \( -regex '.*/\..*' \) | rofi -dmenu -p "Open" )
fi

if [[ $selected != "" ]]
then
echo $selected
ext="`echo $selected | sed 's/\s*.*\.//g' `"
#xdg-open $slected
echo $ext

# image 
if  [[ "$ext" =~ ^(jpg|png|jpeg|tiff)$ ]]; 
then 
   $IMAGE "$selected" 
  exit 0  
fi

# documents 
if  [[ "$ext" =~ ^(pdf)$ ]]; 
then 
   $PDF "$selected" 
  exit 0  
fi


# media player 
if  [[ "$ext" =~ ^(mp4|mkv|mp3|3gp|gif)$ ]];
then
   $VIDEO "$selected" & exit 0 
fi

# filemanager 
if  [  -d   "$ext"   ] ; then
  $FILEMANAGER  "$ext"   & exit 0
fi

# other textfile 
if [ ! -d "$ext" ] ; then
if ! [[ "$ext" =~ ^(mp4|mkv|mp3|3gp|jpg|png|jpeg|tiff)$ ]];
 then
 $TEXTEDIT  "$selected"   &  exit 0
fi
fi 
echo $ext

echo "$selected"
fi

}

function print_usage()
{
 printf 'Usage: %s

        Rofi Fuzzy Finder
Options: 
     --help        Show this message and exit 
     --dir         Search directory to find 
     --player      Change the default video player
     --texteditor  Change the default texteditor
     --filemanager Change the default filemanager
     --imageview   Change the default image viewer

' "${0##*/}"
exit 2
}

#options=$(getopt  --long -o dir:player:texteditor:filemanager:imageview: -- "$@")
#[ $? -eq 0 ] || {
#    echo "Incorrect options provided"
#    exit 1
#}
#eval set -- "$options"
while getopt  "dir:player:texteditor:filemanager:imageview"  options ; do
case  "$1" in
    --help|-h)
    print_usage
    exit 0 
        ;;
    --player)
    VIDEO="$2";
    break
    ;;
   --texteditor)
   TEXTEDIT="$2";
   break
    ;;
    --dir)
      DIR_TO_SEARCH="$2";
      break
      ;;
      --filemanager)
    FILEMANAGER="$2";
    break
        ;;
    --imageview)
    IMAGE="$2";
    break
      ;;
      *)
break
          ;;
esac
done
rofi_main

exit 0 
