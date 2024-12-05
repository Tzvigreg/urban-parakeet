#!/bin/bash

HOME=$(pwd)
USER=$(whoami)

function RESULTS()
{	echo "Time of analysis: $(date)" | tee -a $HOME/Volatility_Tool/$NAME/SUMMARY.txt
	echo "File extracted by Binwalk: $(ls $to_your_binwalk_results_directory | wc -l)" | tee -a $HOME/Volatility_Tool/$NAME/SUMMARY.txt
	echo "File extracted by Foremost: $(ls $to_your_Foremost_results_directory | wc -l)" | tee -a $HOME/Volatility_Tool/$NAME/SUMMARY.txt
	#continue with the rest
	
}

function ALL()
{
	HDD
	VOLATILITY
}

function HDD()
{
	cd $HOME/Volatility_Tool/$NAME
	echo "Running Binwalk.."
	sudo binwalk -e $file
	
	echo "Running foremost..."
	#add the foremost command and save it to the relevant directory.
	
	echo "Running bulk_extractor..."
	bulk_extractor $file -o $HOME/Volatility_Tool/$NAME/bulk > /dev/null 2>&1
	
	echo "Running strings..."
	#loop over extracted exe files - sace the strings output to a simple txt file.  make sure you grep out (using -i) strings related to "user" or "password" - add as many nice and important keywords as you like. 
	#extra if you want - not a must --> ask the user for a keyword and grep it out of the strings output.
	
	# add the rest of the commands based on the relevant tools you download.
	echo "DONE"
	
	
	#checking if a pcap file was extracted
	
	ls -l $HOME/Volatility_Tool/$NAME/bulk | grep packets > /dev/null 2>&1
	if [ "$?" == "0" ]
	then
		SIZE=$(ls -l $HOME/Volatility_Tool/$NAME/bulk | grep packets | awk '{print $5}')
		echo "PCAP file was found! size:$SIZE location:$HOME/Volatility_Tool/$NAME/bulk"
	else
		echo "Couldn't extract PCAP file "
	fi
}



function VOLATILITY()
{
	PROFILE=$($HOME/vol -f $file imageinfo | grep "Suggested Profile" | awk -F',' '{print $1}' | awk -F':' '{print $2}' | sed 's/ //g')
	echo "Investigated Profile: $PROFILE"
	
	PLUGIN="pstree connscan hivelist printkey" ## ADD MORE IF YOU WANT
	for command in $PLUGIN
	do
		echo "Command being used: $command"
		$HOME/vol -f $file --profile=$PROFILE $command >> $HOME/Volatility_Tool/$NAME/file_$command.txt
	done
	
	echo "Done investigating $NAME - results were saved to: $HOME/Volatility_Tool/$NAME"
}

function INSTALL()
{
	if [ -s /usr/bin/binwalk ]
	then
		echo "[+] Binwalk is already installed!"
	else
		echo "[!] Installing binwalk!"
		git clone https://github.com/ReFirmLabs/binwalk.git
		cd binwalk
		#add the rest of the commands for the installation
	fi
	
	if [ -s /usr/bin/foremost ]
	then
		echo "[+] foremost is already installed!"
	else
		echo "[!] Installing foremost!"
		#add the rest of the commands for the installation
	fi

	if [ -s /usr/bin/bulk_extractor ]
	then
		echo "[+] bulk_extractor is already installed!"
	else
		echo "[!] Installing bulk_extractor!"
		#add the rest of the commands for the installation
	fi
	
	if [ -s /usr/bin/strings ]
	then
		echo "[+] strings is already installed!"
	else
		echo "[!] Installing strings!"
		#add the rest of the commands for the installation
	fi
	
	#volatility can come as the stand alone file from the lab
	echo "DONE!"
	
	echo "What memory file would you like to investigate? HDD/RAM/ALL"
	read answer
	if [ "$answer" == "HDD" ]
	then
		HDD
	elif [ "$answer" == "RAM" ]
	then
		VOLATILITY
	elif [ "$answer" == "ALL" ]
	then
		ALL
	else
		echo "Wrong input. try again."
	fi
		
}

function START()
{
	echo "What is the full path to your memory file?"
	read file
	
	if [ -s $file ]
	then
		echo "File exist! continuing..."
		mkdir $HOME/Volatility_Tool > /dev/null 2>&1
		INSTALL
	else
		echo "Wrong input! try again!" 
		START
	fi
	
	NAME=$(basename $file)
	if [ -d $HOME/Volatility_Tool/$file ]
	then
		echo "File with a similar name was investigated in the past.. Directory already exist.."
	else
		mkdir $HOME/Volatility_Tool/$NAME > /dev/null 2>&1
	fi
}


	if [ "$USER" == "root" ]
	then
		echo "You are root! continuing..."
		START
	else
		echo "You are not root! exiting.."
		exit
	fi

