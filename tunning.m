function cost = tunning(K)
assignin('base','K',K);
paramNameValStruct.SimMechanicsOpenEditorOnUpdate = 'off';
simOut = sim("neoArm_14_05_2024.slx",paramNameValStruct);
cost = simOut.error_integral(end)
end
