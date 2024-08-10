PLEASE REPORT ANY BUGS !

TO START USING:
-copy recent.sh file in /usr/local/bin OR add path as environment variable
-make sure that recent.sh has permissions, otherwise use chmod +x
-create folder (can be with dot) for file recent_info.txt
-in .bashrc cerate ALIAS WITH source ! -> for usage $rec
-in your recent.sh file set variable path_to_info -> "ENTER YOUR PATH" to recent_info.txt
-look at your recent_info.txt there is example, clear this file by -> $rec -cl ,then hit ENTER

COMMAND DESCRIPTION:
rec
(recent paths menager)
You can basickly: save path, open, edit, organize list, sort, copy entire list of paths.
Of course list of paths is stored in recent_info.txt, it contatins:
-path
-date
-key
To handle space separated paths words separator is ; (semicolon)
key is file line idetifier
date is using to sort paths by time, and "you know when you added it"
Path can be acces by index (line number) or key (some string)
If some keys are the same -> line wih first maching key is chosing
Key can contain only letters and numbers

key or index is called "id"

###################################################################################################### USAGE:

arguments ONLY this order !!! (depends of chosen $mode)
"$mode" First argument determinants command function, rest arguments specify function
$rec $mode ...

IMPORTANT:
if $mode doesnt fitts to some function -> $mode is processing as id "candidate" to open the path (it can be incorrect)
so $mode is used like: $rec desktop -> then opens your path with key "desktop"

arguments with [] are optional
:n means you can set $id to "n" -> then $id equals to last line of file
if some argumnet is optional it can be default
$id is not a number -> it is processing as key 

$file means any file in folder, where recent_info.txt is stored

defult id is 1 first line "top" 
defult path is pwd current working directory
defult key is "key" 
defult file is recent_info.txt

you will be asked before deleting some line/lines

if file recent_info.txt is empty, message will be displayed, and then you should add new path to use $rec
but you can watch your recent_info.txt copies

###################################################################################################### USE CASES:

[$id] or [$id :n]
$id is defult -> index = 1
$id is "n" -> index = last line

SAVE NEW PATH
$rec -n [$new_path] [$id :n] [$new_key]
IF:
$new_path doesnt exists -> possible arguments are: $id $new_key, default path is setting
$id not maches (or incorrect) -> is it setting as new_key
$id is not specified (or incorrect) -> defult key it setting as new_key
$id is defult -> path is appending to file at the first line "TOP"
$id is "n" -> path is appending to file at the end "BOTTOM"

DISPLAY PATHS
$rec -i [$file]

DISPLAY INFO FILES
$rec -if [$ls_mode]
$ls_mode spacifies ls command flag, like ls -t

OPEN PATH
$rec [$id :n] [$open_mode]
defult &open_mode is "not w"
IF:
$open_mode is NOT "w" cd to chosen path is open in current window
$open_mode is "w" chosen path is open in new window

DELETE PATH
$rec -d [$id :n]

CLEAR ALL PATHS
$rec -cl

COPY INFO FILE
$rec -c $new_file_name
coppies recent_info.txt in folder recent_info.txt is stored

SETS COPY OF INFO FILE
$rec -cs $file_name
sets coppy of recent_info.txt to new recent_info.txt, in folder recent_info.txt is stored

DELTE COPY OF INFO FILE
$rec -df $file_name
coppies recent_info.txt in folder recent_info.txt is stored

UPDATE PATH OR DATE
$rec -u $id [$update_mode]
set path or current time
IF:
$update_mode is "t", then date is updated
$update_mode is correct path, then path is updated
$update_mode is NOT correct path, then path is updated to default path

UPDATE KEY
$rec -k $id [$new_key]

SWAP LINES
$rec -s $id1 $id2

FIND TEXT
$rec -ft $text [$file]
search some text in recent_info.txt file

SORTING:

sort is applied to file -> causes modification !

BY DATE
$rec -t

BY DATE REVERSED
$rec -tr

BY PATH (-a like alphabetically)
$rec -a

BY PATH REVERSED
$rec -ar

BY KEY 
$rec -ak

BY KEY REVERSED
$rec -akr
