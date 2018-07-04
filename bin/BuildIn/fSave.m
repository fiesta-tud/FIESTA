function fSave(dirStatus,frame)
fname = [dirStatus 'frame' int2str(frame) '.mat'];
save(fname,'frame');