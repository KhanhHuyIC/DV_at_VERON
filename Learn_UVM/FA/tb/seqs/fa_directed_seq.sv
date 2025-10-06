class	fa_directed_seq extends fa_base_seq;
	`uvm_object_utils (fa_directed_seq)
	
	task body();
		bit [3:0] a_vec[] = '{4'h0, 4'hF, 4'h1, 4'h8};
		bit [3:0] b_vec[] = '{4'h0, 4'h1, 4'hF, 4'h7};
		foreach (a_vec[i]) begin
			foreach	(b_vec[j]) begin
				foreach	(bit cin in '{0,1}) begin
					fa_txn tr = fa_txn::type_id::create($sformatf("tr_%0d_%0d_%0d", i, j, cin);
					tr.a = a_vec[i];
					tr.b = b_vec[j];
					tr.cin = cin;
					start_item(tr);
					finish_item(tr);
				end
			end
		end
	endtask
	
endclass
