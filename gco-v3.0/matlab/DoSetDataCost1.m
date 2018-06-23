   function DoSetDataCost1(h,dc,thres)
            % Use the sparse mechanism to set dense data costs,
            % to verify that tests all give the same result.
            % Note that this is not a good test when the number
            % of sites is small, since only some of the sparse datacost 
            % code path will get exercised.
            for label=1:size(dc,1)
                ids = find(dc(label,:) < thres);
                GCO_SetDataCost(h,[ids; dc(label,ids)],label);
            end
    end
    