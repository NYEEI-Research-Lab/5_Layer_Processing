//Run this code AFTER doing THE 5_Layer Processing
//Give the code the directory of all the patients that you want to organize
//For exmaple: If you did the 5_Layer for RV250 & RV230, and both are inside a folder called "To_Do", copy that top folder directory

sauce = "K:/AA_Toco_Requests/5_layer_auto/";
sauce = getDirectory("Please give me the directory of the patients you want to sort: ");
pats = getFileList(sauce);
locations = newArray("Fovea/", "Temporal/");
modes = newArray("Angio/", "Enface/");
layers = newArray("Layer_F/", "Layer_C/", "Layer_D/", "Layer_I/", "Layer_S/");
to_be_added = newArray("_OCT", "-Choriocapillaris", "-NewDeep", "-Intermediate", "-Superficial");

//organize fovea folder into Layer_F Angio and OCT
iterations = pats.length;
//iterations = 1;
for (i = 0; i < iterations; i++) {
	for (iloca = 0; iloca < locations.length; iloca++) {
		mini_path = sauce + pats[i] +locations[iloca];
		img_list = getFileList(mini_path);
		//Array.show(img_list);
		for (iimg = 0; iimg < img_list.length; iimg++) {
			if (endsWith(img_list[iimg], ".raw")) {
				ok_boomer = File.delete(mini_path + img_list[iimg]);
			}
			if (endsWith(img_list[iimg], "_OCT.png")) {
				ok_boomer = File.rename(mini_path + img_list[iimg], sauce + pats[i] + locations[iloca] + modes[1] + layers[0] + img_list[iimg]);
			}
			if (endsWith(img_list[iimg], "304.png")) {
				ok_boomer = File.rename(mini_path + img_list[iimg], sauce + pats[i] + locations[iloca] + modes[0] + layers[0] + img_list[iimg]);
			}
			//print("Sorted all Layer _F Images for: " + pats[i] +locations[iloca]);
		}
		print("Sorted all Layer _F Images for: " + pats[i] +locations[iloca]);
		for (imodes = 0; imodes < modes.length; imodes++) {
			new_img_list = getFileList(mini_path + modes[imodes]);
			//Array.show(new_img_list);
			for (inewimg = 0; inewimg < new_img_list.length; inewimg++) {
				for (ilay = 0; ilay < layers.length; ilay++) {
					if (endsWith(new_img_list[inewimg], to_be_added[ilay] + ".png")) {
						ok_boomer = File.rename(mini_path + modes[imodes] + new_img_list[inewimg], mini_path + modes[imodes] + layers[ilay] + new_img_list[inewimg]);
					}
				}
			}	
		}	
		
	}
	print("Fully sorted patient: " +pats[i]);
}
