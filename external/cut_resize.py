import os, sys
import Image, ImageDraw

def resize_border(x_times, border_region, border_x_size, border_y_size, border_num):
	if border_x_size < border_y_size:
		size = border_y_size
		print size

		for x in range(size-1):
			if border_region.getpixel((border_num,x))[0] == 255 and border_region.getpixel((border_num,x+1))[0] == 0: #esli poslednij belij pixel pered poloskoj
				len1=x+1
			else: len1 = 555
			if border_region.getpixel((border_num,x))[0] == 0 and border_region.getpixel((border_num,x+1))[0] == 255: #esli poslednij chornij a potom belij
				len2=x+1
		if len1==555:
			return border_region.resize((1, size/x_times))

		len_white_1 = len1
		len_black = len2 - len1
		len_white_2 = size - len2
		print len_white_1, len_black, len_white_2
		if len_white_1%x_times==0 and len_white_2%x_times==0 and len_black%x_times==0:
			resized_border_x_times = border_region.resize((1, size/x_times))
		else:
			print "cannot resize x_times border for", infile
		resized_border_x_times.save("left_x2.png","PNG")
		return resized_border_x_times

	else:
		size = border_x_size

		for x in range(size-1):
			if border_region.getpixel((x,border_num))[0] == 255 and border_region.getpixel((x+1,border_num))[0] == 0: #esli poslednij belij pixel pered poloskoj
				len1=x+1
			else: len1=555
			if border_region.getpixel((x,border_num))[0] == 0 and border_region.getpixel((x+1,border_num))[0] == 255: #esli poslednij chornij a potom belij
				len2=x+1
		if len1==555:
			return border_region.resize((1, size/x_times))


		len_white_1 = len1
		len_black = len2 - len1
		len_white_2 = size - len2
		if len_white_1%x_times==0 and len_white_2%x_times==0 and len_black%x_times==0:
			resized_border_x_times = border_region.resize((size/2, 1))
		else:
			print "cannot resize x_times border for", infile

		return resized_border_x_times






def main():

	for infile in sys.argv[1:]:
		picture = Image.open(infile)

		xsize = picture.size[0] #razmer napr (512,512)
		ysize = picture.size[1]

		box = (1, 1, xsize - 1, ysize - 1) #oblast' bez kraev        left, upper, right, lower
		region = picture.crop(box)

		left_border = (0,1,1,ysize-1)
		left_border_region = picture.crop(left_border)
		print 1
		resized_left_border_x2 = resize_border(2, left_border_region, 1, ysize-2, 0)
		print 2
		resized_left_border_x4 = resize_border(4, left_border_region, 1, ysize-2, 0)
		print 3
		# resized_left_border_x4.save("left_x4.png","PNG")

		top_border = (1,0,xsize-1,1)
		top_border_region = picture.crop(top_border)
		print 4
		resized_top_border_x2 = resize_border(2, top_border_region, xsize-2, 1, 0)
		print 5
		resized_top_border_x4 = resize_border(4, top_border_region, xsize-2, 1, 0)
		print 6

		right_border = (xsize-1,1,xsize,ysize-1)
		right_border_region = picture.crop(right_border)
		resized_right_border_x2 = resize_border(2, right_border_region, 1, ysize-2, 0)
		print 7
		resized_right_border_x4 = resize_border(4, right_border_region, 1, ysize-2, 0)
		print 8

		bottom_border = (1,ysize-1,xsize-1,ysize)
		bottom_border_region = picture.crop(bottom_border)
		resized_bottom_border_x2 = resize_border(2, bottom_border_region, xsize-2, 1, 0)
		print 9
		resized_bottom_border_x4 = resize_border(4, bottom_border_region, xsize-2, 1, 0)
		print 10


		


		if (xsize-2)%2.0==0 and (ysize-2)%2.0==0:
			print 1
			resized_picture_x2 = region.resize( ((xsize-2)/2, (ysize-2)/2 ))
			# new_box_x2 = (0,0,(xsize-2)/2, (ysize-2)/2)
			# new_picture_x2 = picture.paste(new_box_x2, resized_picture_x2)
			# new_picture_x2.save("new_x2.png","PNG")
		else:
			print "cannot resize x2 for", infile
		
		if (xsize-2)%4.0==0 and (ysize-2)%4.0==0:
			resized_picture_x4 = region.resize( (xsize-2)/4.0, (ysize-2)/4.0 )
		else:
			print "cannot resize x4 for", infile



if __name__ == "__main__":
    main()
