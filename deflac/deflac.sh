#!/bin/sh


CUEPRINT=cueprint
cue_file=""

vorbis()
{
	# FLAC tagging
	# --remove-vc-all overwrites existing comments
	METAFLAC="metaflac --remove-all-tags --import-tags-from=-"

	# Ogg Vorbis tagging
	# -w overwrites existing comments
	# -a appends to existing comments
	VORBISCOMMENT="vorbiscomment -w -c -"

	case "$2" in
	*.[Ff][Ll][Aa][Cc])
		VORBISTAG=$METAFLAC
		;;
	*.[Oo][Gg][Gg])
		VORBISTAG=$VORBISCOMMENT
		;;
	esac
	FILE="$2"
	# space seperated list of recomended stardard field names
	# see http://www.xiph.org/ogg/vorbis/doc/v-comment.html
	# TRACKTOTAL is not in the Xiph recomendation, but is in common use
	
	fields='TITLE VERSION ALBUM TRACKNUMBER TRACKTOTAL ARTIST PERFORMER COPYRIGHT LICENSE ORGANIZATION DESCRIPTION GENRE DATE LOCATION CONTACT ISRC'

	# fields' corresponding cueprint conversion characters
	# seperate alternates with a space

	TITLE='%t'
	VERSION=''
	ALBUM='%T'
	TRACKNUMBER='%n'
	TRACKTOTAL='%N'
	ARTIST='%c %p'
	PERFORMER='%p'
	COPYRIGHT=''
	LICENSE=''
	ORGANIZATION=''
	DESCRIPTION='%m'
	GENRE='%g'
	DATE=''
	LOCATION=''
	CONTACT=''
	ISRC='%i %u'

	(for field in $fields; do
		value=""
		for conv in `eval echo \\$$field`; do
			value=`$CUEPRINT -n "$1" -t "$conv\n" "$cue_file" | iconv --from-code=cp1251`

			if [ -n "$value" ]; then
				echo "$field=$value"
				break
			fi
		done
	done) | $VORBISTAG "$FILE"
}
convert()
{

	cue_file="$1"
	shift

	ntrack=`$CUEPRINT -d '%N' "$cue_file"`
	trackno=1

	if [ $# -ne $ntrack ]; then
		echo "warning: number of files does not match number of tracks"
	fi

	for file in "$@"; do
		case "$file" in
		*.[Ff][Ll][Aa][Cc])
			vorbis $trackno "$file"
			;;
		*)
			echo "$file: uknown file type"
			;;
		esac
		trackno=$(($trackno + 1))
	done
}


mkdir split
cat *.cue | iconv --from-code=cp1251 |  shnsplit -t %a-%t -o flac -d split *.flac
convert *.cue split/*.flac


