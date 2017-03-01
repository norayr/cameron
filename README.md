cameron
========

this program is sort of life hack, which automates routine task of filling out working hours weekly in the BMCSoftware BMC IT Business Management web application. 

it's called Cameron, because Allison Cameron used to do paper work for House.

So this software does paper work for those who must fill out their working hours weekly.

**compile**
for that you need Lazarus (FreePascal IDE).
gui way: open project1.lpi and hit f9.
console way: type lazbuild project1.lpi

**use**
to configure the application choose the tasks from the list and assign priorities to those tasks.
the system will fill out more often activities with higher priorities.

when the program is configured (the config file is stored in the simple text file, which name is the name of your user) login, sit back and relax while this software chooses tasks and fill out the working hours for you.

**customize**

Most probably you need to find out ID's and names for the work types you have in your web application and modify ITCatArray accordingly.

Happy hacking. (:
