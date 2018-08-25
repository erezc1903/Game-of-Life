#include <stdio.h>
#include <math.h>

extern int get_len();
extern int get_cells();
extern int get_world_length();
extern int get_world_width();
extern int get_cell_i_coordinate();
extern int get_cell_j_coordinate();
extern int get_cell_state();


int cell_next_state(int x, int y){

	int row;
	int col;
	int value;
	int current_cell = get_cells();

	int length = get_world_length();
	int width = get_world_width();
	int len = get_len();
	int found = 0;
	/*printf("%d\n", current_cell);*/

	/*printf("x: %d, y: %d\n", x,y);*/
	for (row = 0; row < length && !found; row++){
		for (col = 0; col < width && !found; col++){
			if (get_cell_i_coordinate(current_cell) == x && get_cell_j_coordinate(current_cell) == y){
				/*printf("%d\n", current_cell);*/
				/*printf("cell: %d\n", get_cell_i_coordinate(current_cell));*/
				value = get_cell_state(current_cell);
				found = 1;
				/*printf("value: %d\n", value);*/
			}
			current_cell += len;
		}
		/*current_cell += len;*/
	}

	
	if (value > 0){
		if ((calc_neighbors(x,y) >= 2) && (calc_neighbors(x,y) <= 3)){
			/*printf("calc_neighbors result: %d\n", calc_neighbors(x,y));
			printf("here_1, x: %d, y: %d, value: %d\n", x, y, 1);*/
			return 1;
		}
		/*printf("calc_neighbors result: %d\n", calc_neighbors(x,y));
		printf("here_2, x: %d, y: %d, value: %d\n", x, y, 0);*/
		return 0;
	}
	else{
		if (calc_neighbors(x,y) == 3){
			/*printf("calc_neighbors result: %d\n", calc_neighbors(x,y));
			printf("here_3, x: %d, y: %d, value: %d\n", x, y, 1);*/
			return 1;
		}
		/*printf("calc_neighbors result: %d\n", calc_neighbors(x,y));
		printf("here_4, x: %d, y: %d, value: %d\n", x, y, 0);*/
		return 0;
	}
}

int check_if_alive(int x, int y){
	int row;
	int col;
	int current_cell = get_cells();
	int length = get_world_length();
	int width = get_world_width();
	int len = get_len();
	int value;


	for (row = 0; row < length; row++){
		for (col = 0; col < width; col++){
			if (get_cell_i_coordinate(current_cell) == x && get_cell_j_coordinate(current_cell) == y){
				value = get_cell_state(current_cell);

				if (value > 0){
					return 1;
				}
				return 0;
			}
			current_cell += len;
		}
	}
}

int calc_neighbors(int x, int y){

	int length = get_world_length();
	int width = get_world_width();
	int result = 0;
	int tmp_x = 0;
	int tmp_y = 0;

	tmp_x = correct_coordinate((x-1),length);
	tmp_y = correct_coordinate((y-1),width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x-1, y-1\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/

	tmp_x = correct_coordinate(x,length);
	tmp_y = correct_coordinate((y-1),width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x, y-1\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/

	tmp_x = correct_coordinate((x+1),length);
	tmp_y = correct_coordinate((y-1),width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x+1, y-1\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/

	tmp_x = correct_coordinate((x-1),length);
	tmp_y = correct_coordinate(y,width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x-1, y\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/

	tmp_x = correct_coordinate((x+1),length);
	tmp_y = correct_coordinate(y,width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x+1, y\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/

	tmp_x = correct_coordinate((x-1),length);
	tmp_y = correct_coordinate((y+1),width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x-1, y+1\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/

	tmp_x = correct_coordinate(x,length);
	tmp_y = correct_coordinate((y+1),width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x, y+1\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/

	tmp_x = correct_coordinate((x+1),length);
	tmp_y = correct_coordinate((y+1),width);
	result += check_if_alive(tmp_x,tmp_y);

	/*printf("coordinates: x+1, y+1\n");
	printf("temp_x %d\n", tmp_x);
	printf("temp_y %d\n", tmp_y);
	printf("result %d\n", result);*/
	return result;
}

int correct_coordinate(int a, int b)
{
    int c = a%b;
    if(c<0){
    	return (c+b);
    }
    else{
    	return c;
    }
}





