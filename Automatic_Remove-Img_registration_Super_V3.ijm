//AFTER you have sorted the 5_Layer pt using the 5_Layer_automatic_sorting_OCTA Code
//BEFORE Running this code make sure you made a copy of your 5_Layer processed sorted patients and saved them in a
// sperate fodler called "Unprocessed" 
//RUN this code to register and average the OCTA images. The code will ask you for a folder. 
// Give it the fodler where all the patients that you want to process are located (RV250 & RV251 for example)
//and it will start processgin all of them. It will ask you to remove images based on the number of images you want
//It will then ask you to select a reference image as your basline (when it does just control V) 
//then it will register all images and average them. 
//Variables
total_img = 0;
universal_constant = 0;
undersocre_index = 0;
interuption = 0;
num = 0;

//Arrays
Visits = newArray();
Times = newArray();
Diffs = newArray();
filelist = newArray();
sauce = getDirectory("Give me the directory of the 5 Layer Processing where all the patients are located: ");
//sauce = "C:/Users/LabUser/Documents/SCD_Data/to_do/"
files_sauce = getFileList(sauce);
layers = newArray("Layer_F/", "Layer_C/", "Layer_D/", "Layer_I/", "Layer_S/");
to_be_added = newArray("_OCT", "-Choriocapillaris", "-NewDeep", "-Intermediate", "-Superficial");
folderss = newArray("Angio/", "Enface/");
locations = newArray("Fovea/", "Temporal/");
//locations = newArray("Fovea/");
//locations = newArray("Temporal/");
number_of_visits = getNumber("Please Type the number of Visits", 2);
number_of_img_to_remove = getNumber("Please Type the number of images you want to register", 8);
//number_of_img_to_remove = 10;
iterations = lengthOf(files_sauce);
//iterations = 5;
new_universal_constant = 0;

//Main loop locations
//This loop removes all the images when we call the find_break function
for (main_i = 0; main_i < iterations; main_i++) {
	for (main_j = 0; main_j < lengthOf(locations); main_j++) {
		File.makeDirectory(sauce + files_sauce[main_i] + locations[main_j] + "Removed/");
		for (mini_i = 0; mini_i < lengthOf(folderss); mini_i++) {
			File.makeDirectory(sauce + files_sauce[main_i] + locations[main_j] + "Removed/" + folderss[mini_i]);
		}
		first_direc = sauce + files_sauce[main_i] + locations[main_j] + "Angio/Layer_F/";
		//print(sauce + files_sauce[main_i] + locations[main_j] + "Removed/" + folderss[0]);
		//waitForUser;
		wait_check = getFileList(sauce + files_sauce[main_i] + locations[main_j] + "Removed/" + folderss[0]);
		//wait_check = newArray();
		if (wait_check.length == 0 ) {
			print("We are going to remove images from: " + first_direc);
			v = find_break(first_direc);
			//Array.show(v);
			
		}
	}
}

print("Done Removing Images for all patients");
//This loop does all the registrations
for (patID = 0; patID < iterations; patID++) {
	for (main_i = 0; main_i < locations.length; main_i++) {
		thing_to_do = sauce + files_sauce[patID] + locations[main_i] + "Angio/Layer_F/";
		wait_check = getFileList(thing_to_do + "Registered/");
		if (wait_check.length == 0 ) {
			Initial_registration(thing_to_do);	
			print("Done Registering Images for: " + thing_to_do);
		}
		//print(thing_to_do);
	}
}

print("Done Registering Images for all patients");

//do the transforms
for (patID = 0; patID < iterations; patID++) {
	for (loxa = 0; loxa < locations.length; loxa++) {
		for (fold = 0; fold < lengthOf(folderss); fold++) {
			for (lay = 0; lay < lengthOf(layers); lay++) {
				direc_to_trans = sauce + files_sauce[patID] + locations[loxa] + folderss[fold] + layers[lay];
				loca_of_trans = sauce + files_sauce[patID] + locations[loxa] + folderss[0] + layers[0] + "Transforms/";
				check_wait = getFileList(direc_to_trans + "Registered/");
				print("Going to Transforming Images for: " + direc_to_trans);
				
				if (check_wait.length == 0) {
					transform_stuff(direc_to_trans, loca_of_trans);	
					print("Done Transforming Images for: " + direc_to_trans);
				}
			}
		}
	}
}
print("Done Transforming Images for all patients");

// do the averaging
for (patID = 0; patID < iterations; patID++) {
	for (loxa = 0; loxa < locations.length; loxa++) {
		totalnum_img_for_log = 0;
		direc_for_break = sauce + files_sauce[patID] + locations[loxa] + folderss[0] + layers[0] + "Registered/";
		//print(direc_for_break);
		index_array = newArray();
		axial_length_file = File.openAsString(sauce + files_sauce[patID] + "Axial lengh.txt");
		axial_length_file = replace(axial_length_file, "\n", "");
		index_array = Array.concat(index_array, indexOf(axial_length_file, 1));
		index_array = Array.concat(index_array, indexOf(axial_length_file, 2));
		index_array = Array.concat(index_array, indexOf(axial_length_file, 3));
		
		//Array.show(index_array);
		for (i_index = 0; i_index < index_array.length; i_index++) {
			if (index_array[i_index] < 0) {
				index_array[i_index] = 1000;		
			}
		}
		poop = Array.findMinima(index_array, 1);
		//Array.show(poop);
		axial_length_real = substring(axial_length_file, index_array[poop[0]]); 
		breakpoint_array = find_break(direc_for_break);
		//Array.show(breakpoint_array);
		for (fold = 0; fold < lengthOf(folderss); fold++) {
			for (lay = 0; lay < lengthOf(layers); lay++) {
				string2="";
				direc_for_avg = sauce + files_sauce[patID] + locations[loxa] + folderss[fold] + layers[lay];
				for (num_visit = 0; num_visit < breakpoint_array.length; num_visit++) {
					avg_stuff(direc_for_avg, breakpoint_array[num_visit], num_visit +1, new_universal_constant, axial_length_real);
					new_universal_constant = new_universal_constant + breakpoint_array[num_visit];
					string1 = "Session number: " + num_visit+1 + " has " +  breakpoint_array[num_visit] + " images" + "\n";
					string2 = string1 + string2;
					totalnum_img_for_log = totalnum_img_for_log + breakpoint_array[num_visit];
				}
				new_universal_constant = 0;
				print("Done Averaging Images for: " + direc_for_avg);
				path1 = sauce + files_sauce[patID] + locations[loxa];
				
				string_to_save = path1 + "\n" +path1 + "\n" + "Total number of visits: " + number_of_visits + "\n" + string2 + "Total number of images: " + totalnum_img_for_log;
				//path1 = "C:/Users/LabUser/Documents/SCD_Data/5_Layer_Processing/RV002_Visit3/Fovea/log.txt";
				File.saveString(string_to_save, path1 + "log.txt");
				totalnum_img_for_log = 0;
			}
		}
	}
}

print("Done Averaging Images for all patients");





print("Done with the code!");




//From here on these are all the functions

function transform_stuff(directory_to_be_transform, location_of_transforms) { 
// function description
	output_for_img = directory_to_be_transform + "Registered/";
	run("Transform Virtual Stack Slices", "source="+ directory_to_be_transform + " output=" + output_for_img + " transforms=" + location_of_transforms + " interpolate");
	close("*");
}



function avg_stuff(directory_for_avg, img_num, visit_number, new_universal_constant, axial_length) { 
// function description
	File.makeDirectory(directory_for_avg + "Matlab/");
	cancel_check = getFileList(directory_for_avg + "Matlab/");
	final_check = cancel_check.length;
	final_check = 0;
	if (final_check > 0) {
		return ;
	}
	avg_filelist = getFileList(directory_for_avg + "Registered/");
	//Array.show(avg_filelist);
	for (to_open = 0; to_open < img_num; to_open++) {
		//print(directory_for_avg  +"Registered/" +avg_filelist[to_open + new_universal_constant]);
		open(directory_for_avg  +"Registered/" + avg_filelist[to_open + new_universal_constant]);
	}
	if (img_num >1) {
		run("*Images to Stack [F1]");
		run("Z Project...", "projection=[Average Intensity]");
	}
		run("Save", "save=[" + directory_for_avg + "Matlab/" + "AVG_Stack0" + visit_number + ".tif]");
		close("*");
		to_save = File.open(directory_for_avg + "Matlab/" + "AL.txt");
		//to_save = File.makeDirectory(directory_for_avg + "Matlab/" + "AL.txt");
		print(to_save, axial_length);
		File.close(to_save);
}







function find_break(directory_for_break) {
	am_i_crazy = 0;
	universal_constant = 0;
	Visits = newArray();
	Times = newArray();
	Diffs = newArray();
	filelist = newArray();
	// function description
	bad_filelist = getFileList(directory_for_break);
	//Array.show(bad_filelist);
	
	for (lent = 0;lent < lengthOf(bad_filelist); lent++) {
		if (endsWith(bad_filelist[lent], ".png") || endsWith(bad_filelist[lent], ".tif")) {
			filelist = Array.concat(filelist, bad_filelist[lent]);
		}
	}
	//Array.show(filelist);
	//waitForUser;
	if (number_of_visits == 1) {
	Visits = Array.concat(Visits, lengthOf(filelist));
	total_img += Visits[0];
	interuption = 0;
	} else { 
		for (j = 0; j < lengthOf(filelist); j++) {
			if (endsWith(filelist[j], ".png")|| endsWith(filelist[j], ".tif")) {
				for (i = 0; i < 6; i++) {
					undersocre_index = indexOf(filelist[j], "_", undersocre_index);
					undersocre_index = indexOf(filelist[j], "_", undersocre_index +1);
				}
				image_substring = substring(filelist[j], undersocre_index +1, undersocre_index + 11);
				image_substring = replace(image_substring, "-", "");
				image_substring = Math.abs(image_substring);
				Dates = Array.concat(Dates, image_substring);
				//Dates = Array.concat(Dates, substring(filelist[j], ind +1, ind + 11));
				provisional = replace(substring(filelist[j], undersocre_index +12, undersocre_index + 20), "-", "");
				//print(provisional);
				realtime = Math.abs(substring(provisional, 0, 2))*3600 + Math.abs(substring(provisional, 2, 4))*60 + Math.abs(substring(provisional, 4, 6));
				//print(realtime);
				//waitForUser;
				Times = Array.concat(Times, realtime);
				undersocre_index = 0;
			}
		}
		//Array.show(Times);
		//waitForUser;
		for (i = 0; i < lengthOf(Times)- 1; i++) {
			Diffs = Array.concat(Diffs, Times[i+1] - Times[i]);
		}
		
		Dif_sort = Array.copy(Diffs);
		Dif_sort = Array.sort(Dif_sort);
		Dif_sort = Array.invert(Dif_sort);
	
		for (i = 0; i < Diffs.length; i++) {
			if (Dif_sort[0] == Diffs[i]) {
				interuption = i +1;
			}
		}
		
		Visits = Array.concat(Visits, interuption);
		Visits = Array.concat(Visits, lengthOf(filelist) - interuption);
	
	}
	//Array.show(Visits);
	//Array.show(Diffs);


			for (k = 0; k < number_of_visits; k++) {
			//for each folder we sill save k AVGs where k = number_of_visits
				for (m = 0; m < Visits[k]; m++) {
					//print(m);
				 	if (endsWith(filelist[m + universal_constant], ".png")) { 
				 	//print(directory_for_break + filelist[m + universal_constant]);
		       		open(directory_for_break + filelist[m + universal_constant]);
		       		num= num+1;
		       	}
		      } if (num>1) {
		       	run("*Images to Stack [F1]");
		       	num = 0;
		       }
		       num = 0;
	am_i_crazy = remove_images(directory_for_break, Visits[k]);
	//print(am_i_crazy);
	//waitForUser;
	universal_constant = universal_constant + Visits[k];
	if (number_of_visits == 1) {
			universal_constant = 0;
		}
	//print(universal_constant);
	//waitForUser;
	}
	
	return Visits;
}



function remove_images(directory_for_break, number_of_img_open) { 
// function description
	directory_for_break = substring(directory_for_break, 0, directory_for_break.length -14);
	//print(directory_for_break);
	//waitForUser;
	if (number_of_img_open - number_of_img_to_remove > 0) {
		print(directory_for_break);
		run("In [+]");
		run("In [+]");
		selectWindow("Stack");
		waitForUser("Please scroll through the stack and remember " + number_of_img_open - number_of_img_to_remove + " numbers of the images you want to remove from the stack");
		selectWindow("Stack");
	}
		//waitForUser;
	for (lolol = 0; lolol < number_of_img_open - number_of_img_to_remove; lolol++) {
		image_to_remove = getNumber("Write the number of the image you wish to remove", 1);
		real_num = image_to_remove + universal_constant -1;
		//print(real_num);
		//loop through angio and enface //layers and to_be_added
		for (modality = 0; modality < lengthOf(folderss); modality++) {
			//loop through all the layers
			for (layer_to_loop = 0; layer_to_loop < lengthOf(layers); layer_to_loop++) {
				ending = replace(filelist[real_num], ".png", to_be_added[layer_to_loop] + ".png");
				path1 = directory_for_break + folderss[modality] + layers[layer_to_loop] + ending;
				path2 = directory_for_break + "Removed/" + folderss[modality] + ending;
				if (modality == 0 && layer_to_loop == 0) {
					//AKA If we are doing the Angio Full layer
					path1 = directory_for_break + folderss[modality] + layers[layer_to_loop] + filelist[real_num];
					path2 = directory_for_break + "Removed/" + folderss[modality] + filelist[real_num];
				}
		//print("Path1 is: " + path1);
		//print("Path2 is: " + path2);
		ok_boomer = File.rename(path1, path2);
		//File.rename(path1, path2);
		//print(ok_boomer);
			}
		}
		real_num = 0;
	}
	close("*");
	return number_of_img_open - number_of_img_to_remove;

}



function Initial_registration(sauce_for_registration) { 
	// function description
	outt = sauce_for_registration  + "/Registered";
	sauce_to_be_copied = replace(sauce_for_registration, "/", "\\");
	String.copy(sauce_to_be_copied);
	run("Register Virtual Stack Slices", "source=" + sauce_for_registration + " output=" + outt + " feature=Rigid registration_hello=[Elastic              -- bUnwarpJ splines                    ] advanced save initial_gaussian_blur=1.05 steps_per_scale_octave=3 minimum_image_size=64 maximum_image_size=1024 feature_descriptor_size=8 feature_descriptor_orientation_bins=8 closest/next_closest_ratio=0.92 maximal_alignment_error=25 inlier_ratio=0.05 feature_extraction_model=Rigid registration_model=[Elastic              -- bUnwarpJ splines                    ] interpolate registration_reg=Mono image_subsample_factor=0 initial_deformation=Coarse final_deformation=Coarse divergence_weight=0 curl_weight=0 landmark_weight=0 image_weight=1 consistency_weight=10 stop_threshold=0.01");
	doCommand("Start Animation [\\]");
	are_you_happy = getBoolean("Are you happy with the registration? ");
	close("*");
	if (are_you_happy == 0) {
		to_be_deleted = getFileList(outt);
		for (jk = 0; jk < to_be_deleted.length; jk++) {
			bye_boomer = File.delete(outt + "/" + to_be_deleted[jk]);
		}
		Initial_registration(sauce_for_registration);
	}else {
		String.copy(first_direc);
		return;
	}
}


