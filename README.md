# *Not official*

The use of this script is at your own risk.  
I created this based on limited usecase.

# Usage

+ git clone git@github.com:jmatsu/updatefiles.git
+ cd /path/to/this
+ ./update.sh `query` `copyee_file` `copy_to_files...`
+ Check contents of new files
+ If it's/they're correct, move/overwrite your local file(s).

# Notes

+ Never use this with file redirection
+ This doesn't overwrite specified files
+ This creates new files
+ Each parameters of json must be single line

## Sample case

```sh
./update "slide_url" samples/sessions_ja.json samples/sessions_en.json samples/sessions_ar.json 
#=> create samples/sessions_en.json.revised samples/sessions_ar.json.revised
```

Check the "slide_url" line of `samples/sessions_en.json.revised` and `samples/sessions_ar.json.revised`.  
e.g. `diff samples/sessions_en.json samples/sessions_en.json.revised`

# Ready

`query` : The name of json parameters. In sample case, `query` is "slide_url". 

`copyee_file` : The revised file (create manually... :bow:). In sample case, `copyee_file` is `sessions_ja.json` and this only has the value of "slide_url".

`copy_to_files` : The files which you would like to update. In sample case,`sessions_en.json` and `sessions_ar.json`
