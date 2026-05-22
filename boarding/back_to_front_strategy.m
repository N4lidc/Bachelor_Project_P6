function gate_queue = back_to_front_strategy(P, N)
    passenger_ids = 1:N;
    rows = [P.assigned_row];
    [~, order] = sort(rows, "descend");
    gate_queue = passenger_ids(order);
end
