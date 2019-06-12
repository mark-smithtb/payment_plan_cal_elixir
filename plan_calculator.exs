defmodule PlanCalculator do
  @months %{"1": "Jan", "2": "Feb", "3": "Mar", "4": "Apr", "5": "May", "6": "Jun", "7": "July", "8": "Aug", "9": "Sept", "10": "Oct", "11": "Nov", "12": "Dec"}
  @moduledoc false
  def get_months(0, result), do: result

  def get_months(number, result) do
    today = Date.utc_today
    next_month(number - 1, [current_month(today)], today)
  end

  def current_month(date) do
    month = date.month
    month_string = Integer.to_string(month)
    month = Map.get(@months, String.to_atom(month_string))
  end


  def next_month(0, month_arr, date), do: month_arr


  def next_month(number, month_arr, date) do
    day = date.day
    days_this_month = Date.days_in_month(date)
    new_date  = Date.add(date, days_this_month - day + 1)
    next_month = new_date.month
    month_string = Integer.to_string(next_month)
    month = Map.get(@months, String.to_atom(month_string))
    new_month_arr = month_arr ++ [month]
    next_month(number - 1, new_month_arr, new_date)
  end

  def calculate_payment([], accounts_arr, payment, result), do: result


  def calculate_payment([h| t], accounts_arr, payment, result) do
    new_accounts_arr = make_payment(payment, accounts_arr, [])
    new_result = Map.put(result, h, new_accounts_arr)
    if Enum.any?(new_accounts_arr, fn account -> account.amount == 0 and account.cost > 0  end) do
      cost_accounts = Enum.filter(new_accounts_arr, fn account -> account.amount == 0  and account.cost > 0 end)
      costs = Enum.map(cost_accounts, fn account-> account.cost end)
      savings = Enum.sum(costs)
      remaining_accounts_arr = Enum.filter(new_accounts_arr, fn account -> account.amount > 0  end)
      new_payment = payment + savings
      calculate_payment(t, remaining_accounts_arr, new_payment, new_result)
    else
    calculate_payment(t, new_accounts_arr, payment, new_result)
    end
  end

  def make_payment(0, accounts_arr, result), do: result

  def make_payment(payment, [], result), do: result


  def make_payment(payment, [h | t], result ) do
    remaining_amount = Map.get(h, :amount) - payment
    if remaining_amount > 0 do
      paid_account = Map.update(h, :amount, 0, &(&1 - payment))
      new_result = [paid_account | t]

      make_payment(0, new_result, new_result)
    else
      paid_account = Map.update(h, :amount, 0, &(&1 = 0))
      new_result =  t ++ [paid_account | []]
      remaining_amount = abs(remaining_amount)
      if Enum.all?(new_result, fn account -> account.amount == 0  end) do
        make_payment(remaining_amount, [] , new_result)
      else
      make_payment(remaining_amount, new_result , new_result)
      end
    end

  end



  def calculate(starting_payment, number_of_months, accounts_arr ) do
    months = get_months(number_of_months, [])
    calculate_payment(months, accounts_arr, starting_payment, %{})
  end
end

IO.inspect PlanCalculator.calculate(1701,
                                    10,
                                    [ %{name: 'amex', amount: 505, cost: 43},
                                      %{name: 'paypal', amount: 2768, cost: 81},
                                      %{name: 'shipping', amount: 4000, cost: 77},
                                      %{name: 'capital one', amount: 3476, cost: 109},
                                    %{name: 'bike', amount: 8000, cost: 0}])



