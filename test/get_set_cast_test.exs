defmodule GetSetCastTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.{Book, User}

  describe "get" do
    defmodule GetBirthdayForm do
      use SmartForm

      fields do
        field :birthday, :date, get: :localized_date
      end

      def localized_date(name, source) do
        date = Map.get(source, name)
        date && Calendar.strftime(date, "%d/%m/%Y")
      end
    end

    test "should return the value returned by the get function" do
      user = %User{birthday: ~D[2010-12-23]}
      form = GetBirthdayForm.new(user)
      assert form.data.birthday == "23/12/2010"
    end

    defmodule GetPriceForm do
      use SmartForm

      fields do
        field :price, :string, get: :localized_price
      end

      def localized_price(:price, source) do
        if source.price_cents do
          (source.price_cents / 100.0) |> :erlang.float_to_binary(decimals: 2)
        end
      end
    end

    test "should return the value returned by the set function" do
      form = GetPriceForm.new(%Book{price_cents: 1000, price_currency: "USD"})
      assert form.data.price == "10.00"
    end
  end
end
