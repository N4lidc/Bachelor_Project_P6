function gate_queue = half_block_mix_strategy(P, N, J)

    passenger_ids = 1:N;
    rows = [P.assigned_row];
    seats = [P.seat_number];

    row_group = min(5, floor((rows - 1) * 5 / J) + 1);

    side = zeros(1, N);

    for i = 1:N
        if seats(i) == 0 || seats(i) == 1 || seats(i) == 2
            side(i) = 1;   % left side
        elseif seats(i) == 3 || seats(i) == 4 || seats(i) == 5
            side(i) = 2;   % right side
        else
            error("Invalid seat number for passenger %d: %d", i, seats(i));
        end
    end

    zone_order = [
        5 1
        4 2
        3 1
        2 2
        1 1
        5 2
        4 1
        3 2
        2 1
        1 2
    ];

    gate_queue = [];

    for z = 1:size(zone_order, 1)
        target_row_group = zone_order(z, 1);
        target_side = zone_order(z, 2);

        zone_passengers = passenger_ids(row_group == target_row_group & side == target_side);

        % Mix passengers inside the same zone
        if ~isempty(zone_passengers)
            zone_passengers = zone_passengers(randperm(length(zone_passengers)));
        end

        gate_queue = [gate_queue, zone_passengers];
    end
end
