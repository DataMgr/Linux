#!/bin/sh
 
i_from="$1"
i_to="$2"
i_content="$3"
i_attachments="$4"

d_from="sender@example.com"
d_to="reciever@example.com"
d_content="test send mail" 


from=${i_from:=$d_from} 
to=${i_to:=$d_to} 
body=${i_content:=$d_content} 
 

subject="Oracle monitor"  

declare -a attachments
#attachments=( "a.pdf" "b.zip" )
attachments=$i_attachments

#deal with attachment args
declare -a attargs

for att in "${attachments[@]}"; do
   [ ! -f "$att" ] && echo "Warning: attachment $att not found, skipping" >&2 && continue	
  attargs+=( "-a"  "$att" )
done

mail -s "$subject" -r "$from" "${attargs[@]}" "$to" <<< "$body"
