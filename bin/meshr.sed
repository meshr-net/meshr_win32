#sed -f bin/meshr.sed -i ./etc/init.d/olsrd
#/usr/bin/find . -type f -print0 | xargs -0 sed -f bin/meshr.sed -i 
#export PATH=$PATH:/${meshr/:/\/}/bin
s/\([^a-zA-Z]\)\/lib/\1\$meshr\/lib/g
s/\([^a-zA-Z]\)\/usr/\1\$meshr\/usr/g
s/\([^a-zA-Z]\)\/var/\1\$meshr\/var/g
s/\([^a-zA-Z]\)\/tmp/\1\$meshr\/tmp/g
s/\([^a-zA-Z]\)\/dev/\1\$meshr\/tmp/g
s/\([^a-zA-Z]\)\/etc/\1\$meshr\/etc/g
s/\([^a-zA-Z]\)\/sbin/\1\$meshr\/sbin/g
s/$IPKG_INSTROOT/${IPKG_INSTROOT:-$meshr}/g
#sed -i 's/[^a-zA-Z]\/lib/\$meshr\/lib/g' 
#sed -i 's/[^a-zA-Z]\/usr/\$meshr\/lib/g'