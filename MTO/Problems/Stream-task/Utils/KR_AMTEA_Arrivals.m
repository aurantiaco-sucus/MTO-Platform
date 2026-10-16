function arrival = KR_AMTEA_Arrivals(tasks, maxFE, seed)
% Sample integer FE arrivals using Eq. (21), then shift the earliest arrival to zero.
% Use a save/restore scope under Octave, which has no RandStream class.
% This keeps arrival generation isolated from the platform RNG state.
previous = rng();
cleanup = onCleanup(@() rng(previous)); %#ok<NASGU>
rng(seed, 'twister');
arrival = randi(maxFE, 1, tasks);
arrival = arrival - min(arrival);
end
