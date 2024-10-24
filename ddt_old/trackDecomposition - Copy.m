%% Create Track x, y coordinates from velocity and yaw velocity
function trackDetails = trackDecomposition(time, velocity, yawVel)

    velocity = velocity*(1609.34/3600);                             % m/s
    yawVel = yawVel(lapNum_index)*(3.1415/180);         % rad/s

    numVals = length(time);
    vehicleHeading = zeros(numVals,1);
    xpos = zeros(numVals,1);
    ypos = zeros(numVals,1);   

    % first pass of vehicle heading
    for t = 2:numVals
        prevHeading = vehicleHeading(t-1);  % rad
        timeDelta = time(t) - time(t-1);    % s
        vehicleHeading(t) = prevHeading + yawVel(t)*timeDelta;
    end
    
    
    idx = input("what is the max index where car is static?: ");

    % correct vehicle heading
    h0 = vehicleHeading(1);
    h1 = vehicleHeading(idx);
    t0 = time(1);
    t1 = time(idx);

    dt = t1-t0;
    dh = h1 - h0;
    heading_thermalDrift = dh/dt;
    netDrift = heading_thermalDrift*time(numVals);
    drift_v_time = 0:(netDrift/numVals):netDrift;

    % calculate xpos and ypos
    for t = 2:numVals
        timeDelta = time(t) - time(t-1);
        vehicleHeading(t) = vehicleHeading(t) - drift_v_time(t);
        avgHeading = (vehicleHeading(t)+vehicleHeading(t-1))/2;
        xpos(t) = xpos(t-1) + velocity(t)*cos(avgHeading)*timeDelta;
        ypos(t) = ypos(t-1) + velocity(t)*sin(avgHeading)*timeDelta;

    end

    % format the output
    trackDetails = [vehicleHeading(:,1), xpos(:,1), ypos(:,1)];
    varNames = ["vehicleHeading", "xpos_m", "ypos_m"];
    trackDetails = array2table(trackDetails);
    trackDetails.Properties.VariableNames = varNames;
    
end