function events = push(events, time, prio, type, pid)
events(end+1,:) = [time prio type pid];
end
