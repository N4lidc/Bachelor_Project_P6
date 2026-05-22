function gate_queue = steffen_strategy(P, N, J)

    passenger_ids = 1:N;
    rows = [P.assigned_row];
    seats = [P.seat_number];

    gate_queue = [];

    seat_order = [0 5 1 4 2 3];

    parity_order = [mod(J, 2), 1 - mod(J, 2)];

    for s = 1:length(seat_order)
        target_seat = seat_order(s);

        for p = 1:length(parity_order)
            target_parity = parity_order(p);

            for r = J:-1:1
                if mod(r, 2) == target_parity
                    idx = find(rows == r & seats == target_seat);

                    if ~isempty(idx)
                        gate_queue = [gate_queue, passenger_ids(idx)];
                    end
                end
            end
        end
    end
end
