function [assigned_row, seat_number] = assign_unique_seats(N, J)
all_slots = randperm(J*6, N); 

assigned_row = ceil(all_slots / 6); 
seat_number = mod(all_slots - 1, 6); 
end
