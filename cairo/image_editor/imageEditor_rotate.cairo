use array::ArrayTrait;
use option::OptionTrait;
use box::BoxTrait;

fn rotateImage90DegreesClockwise(arr_len:felt, arr:felt*,width:felt252,length:felt252)->Array<felt252>{

    let mut new_image=ArrayTrait::new();
    let mut i:u128=0;
    let mut j:u128=0;

    //        for (int i = 0; i < width; i++) {
    //    for (int j = 0; j < height; j++) {
    //        rotatedImage[j][width - 1 - i] = originalImage[i][j];
    //    }
    //}
    //first line- i=0. 
    //third line- i=3, j=0, I want to put the item in third 

    //int[][] image = {
    //     {1, 2, 3},
    //     {4, 5, 6},
    //     {7, 8, 9}... to  {7, 4, 1},
    //                      {8, 5, 2},
    //                      {9, 6, 3}
    // };
    loop{
        if i>length{
            break;
        }

        loop {
            if j>width{
                break;
            }
            new_image[(j * width) + (width - i - 1)]=arr[(i*height)+j];

        }
    }

    return new_image;
}

fn sqrt(n: felt) -> (result: felt):
    alloc_locals
    // Handle special cases
    if n == 0:
        return (0)
    end
    if n == 1:
        return (1)
    end

    // Initialize the binary search bounds
    let mut low = 1
    let mut high = n
    let mut result = 1

    // Binary search for the square root
    while low <= high:
        let mid = (low + high) / 2
        let mid_squared = mid * mid

        if mid_squared == n:
            return (mid)
        end
        if mid_squared < n:
            low = mid + 1
            result = mid
        else:
            high = mid - 1
        end
    end

    return (result)
end