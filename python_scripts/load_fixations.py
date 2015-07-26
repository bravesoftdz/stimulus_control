import os
import csv

import matplotlib.pyplot as plt
import numpy as np

# fixations on surface left
# id start_timestamp duration start_frame end_frame norm_pos_x norm_pos_y x_scaled y_scaled on_srf

def load_AB_fixations(rec_dir):
	def load_sections(sections_slice, surface_name):
		"""
		loading (id, duration, on_srf)
		"""
		all_fixations = []
		for dir_name in names[sections_slice]:
			metrics_path = os.path.join(rec_dir, dir_name)
			for _, _, files in os.walk(metrics_path):
				for file_name in files:
					if "".join(['fixations_on_surface_',surface_name]) in file_name:
						file_path = os.path.join(metrics_path, file_name)
						fixations = np.genfromtxt(file_path, delimiter="\t", usecols=[0, 2, 9], dtype=['int','float', 'bool'], names=True)
						all_fixations.append({'dir_name':dir_name,'fixations':fixations})
		return all_fixations

	# if necessary, use natural sorting
	# from natsort import natsorted
	for _, directories, _ in os.walk(rec_dir):
		names = [dir_name for dir_name in directories]
		names = sorted(names)
		break

	A = slice(0, len(names)+1, 2)
	B = slice(1, len(names)+1, 2)

	return load_sections(A, 'Left'), load_sections(B, 'Left'), load_sections(A, 'Right'), load_sections(B, 'Right')

if __name__ == "__main__":
	rec_dir = []
	rec_dir.append('/home/rafael/pupil-o/recordings/2015_05_27/cristiane/001')
	rec_dir.append('/home/rafael/pupil-o/recordings/2015_05_27/cristiane/002/x-0.3')
	rec_dir.append('/home/rafael/pupil-o/recordings/2015_05_27/cristiane/003')

	sessions = []
	for directory in rec_dir:
		AL, BL, AR, BR = load_AB_fixations(directory)
		sessions.append( {'AL_sections': AL, 'BL_sections': BL, 'AL_sections': AR, 'BL_sections': BR } )

	for session in sessions:
		for section in session['AL_sections']:
			for fixation in section['fixations']:
				if fixation['on_srf']:
					print fixation['duration']

	# figure = plt.figure()
	# axes = figure.add_axes([0.1, 0.1, 0.8, 0.8])

	# axes.plot(some_data, 'k.')

	# x_label = 'x'
	# y_label = 'y'
	# title = ''

	# axes.set_xlabel(x_label)
	# axes.set_ylabel(y_label)  
	# axes.set_title(title);

	# # lets check the results
	# plt.show()