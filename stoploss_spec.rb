require './stoploss.rb'

describe StopLoss, '#handle' do
	it 'does nothing when new price is same as current price' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		action = stoploss.handle :price_changed, 10
		action.should == :do_nothing
	end
	it 'does nothing when new price is higher than current price' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		action = stoploss.handle :price_changed, 11
		action.should == :do_nothing
	end
	it 'does nothing when new price is lower than current price but within the trail' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		action = stoploss.handle :price_changed, 9.5
		action.should == :do_nothing
	end
	it 'triggers sell when new price is equal to current price minus trail' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		action = stoploss.handle :price_changed, 9
		action.should == :sell
	end
	it 'does nothing when price moves up then down within threshold' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		stoploss.handle :price_changed, 11
		action = stoploss.handle :price_changed, 10.5
		action.should == :do_nothing
	end
	it 'triggers sell when price moves up and holds then moves down below threshold' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		stoploss.handle :price_changed, 11
		stoploss.handle :time_changed, 15
		action = stoploss.handle :price_changed, 9.5
		action.should == :sell
	end
end

describe StopLoss, '#current_price' do
	it 'stays the same when the new price is the same' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		stoploss.handle :price_changed, 10
		stoploss.current_price.should == 10
	end
	it 'stays the same when the new price is lower' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		stoploss.handle :price_changed, 9
		stoploss.current_price.should == 10
	end
	it 'is increased when the new price is higher and delta_for_price_up has elapsed' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		stoploss.handle :price_changed, 11
		stoploss.handle :time_changed, 15
		stoploss.current_price.should == 11
	end
	it 'stays the same when the new price is higher and delta_for_price_up has not elapsed' do
		stoploss = StopLoss.new 1
		stoploss.handle :price_changed, 10
		stoploss.handle :price_changed, 11
		stoploss.handle :time_changed, 9
		stoploss.current_price.should == 10
	end
end

describe StopLoss, '#time_since_last_price_change' do
	it 'increases correctly' do
		stoploss = StopLoss.new 1
		stoploss.handle :time_changed, 1
		stoploss.handle :time_changed, 3
		stoploss.handle :time_changed, 5
		stoploss.time_since_last_price_change.should == 9
	end	
end
