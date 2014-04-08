#!/bin/bash

#Ugly hack to force all files to be updated
#find . -name '*.m' -exec touch {} \;


# Send imaging code to web and DropBox
tar -zcf imagingCode.tgz  ../maths ../plotting ../stats ../misc examples/ display/ html/ import/ info.xml Prairie/ preProcessing/ *.txt registrationFunctions/ ROIstats/ summarizeRecording/ testCode/ utilityFunctions/
#tar -zcf imagingCodeTurnerLab.tgz   ../maths ../plotting ../stats ../misc import/ preProcessing/ display/ testCode/ KCstats/ DiscriminantAnalysis/ KCtuningCurves/ unsupervisedClustering/ summarizeRecording/ utilityFunctions/ readme.txt info.xml

scp  imagingCode.tgz campbell@webpro.cshl.edu:~/www/code/
rm -f imagingCode.tgz 

echo "Copying to DropBox"

#rsync -a --delete examples import preProcessing display testCode KCstats summarizeRecording utilityFunctions html info.xml readme.txt ~/Dropbox/PublicImagingCode/ImagingCode/

#rsync -a --delete  ../CellSort1.2 ../maths ../plotting ../stats ../misc ~/Dropbox/PublicImagingCode/OtherMatlabFunctions/

rsync -av --delete  ../ImagingAnalysis ../maths ../misc ../plotting ../stats  ~/Dropbox/PrivateImagingCode/



#Delete backup files in Dropbox
find ~/Dropbox/PublicImagingCode/ -name '*~' -exec rm -f {} \;
find ~/Dropbox/PrivateImagingCode/ -name '*~' -exec rm -f {} \;
