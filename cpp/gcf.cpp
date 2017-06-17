#include <fstream>
#include <iostream>
#include <cmath>
#include <ctime>

using namespace std;

int recursive_gcf(int x1, int x2) {
    if(x2 == 0) {
        return x1;
    }

    return recursive_gcf(x2, x1 % x2);
}

int main()
{
    ifstream val_input;
    int num_vals;
    clock_t begin, end;
    double exec_time;

    val_input.open("../data/input.in");
    val_input >> num_vals;  // gets number of values in file

    int *input_data = new int[num_vals];

    // read into array
    begin = clock();
    for (int a = 0; a < num_vals; a++) {
        val_input >> input_data[a];
        input_data[a] = abs(input_data[a]);
    }

    int val;
    for (int i = 0; i < (num_vals - 1); i++) {
        if (i == 0) {
            val = recursive_gcf(input_data[i], input_data[i+1]);
        } else {
            val = recursive_gcf(val, input_data[i+1]);
        }
    }
    end = clock();

    exec_time = (end - begin) / static_cast<double>( CLOCKS_PER_SEC );

    cout << "GCF is " << val << endl;
    printf("Took %lf ms", exec_time);

    return 0;
}
