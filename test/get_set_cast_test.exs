defmodule GetSetCastTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.{Book, User}

  describe "get" do
    defmodule GetBirthdayForm do
      use SmartForm

      smart_form do
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

      smart_form do
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

  describe "set" do
    defmodule SetBirthdayForm do
      use SmartForm

      smart_form do
        field :birthday, :date, set: :parse_date
      end

      def parse_date(_name, value) do
        if value do
          [day, month, year] = String.split(value, "/") |> Enum.map(&String.to_integer/1)
          Date.new!(year, month, day)
        end
      end
    end

    test "should return the value returned by the set function" do
      form = %User{} |> SetBirthdayForm.new()

      changeset =
        form
        |> SetBirthdayForm.validate(%{"birthday" => "23/12/2010"})
        |> SetBirthdayForm.changeset()

      assert changeset.changes.birthday == ~D[2010-12-23]
    end
  end

  describe "get with context" do
    defmodule GetContextBirthdayForm do
      use SmartForm

      smart_form do
        field :birthday, :date, get: :localized_date
      end

      def localized_date(name, source, context) do
        date = Map.get(source, name)
        date && Calendar.strftime(date, context.date_format)
      end
    end

    test "it should pass the context to the get function" do
      user = %User{birthday: ~D[2010-12-23]}
      form = GetContextBirthdayForm.new(user, %{date_format: "%d/%m/%Y"})
      assert form.data.birthday == "23/12/2010"
    end
  end

  describe "set with context" do
    defmodule SetContextBirthdayForm do
      use SmartForm

      smart_form do
        field :birthday, :date, set: :parse_date
      end

      def parse_date(_name, value, context) do
        if value do
          case context.date_format do
            "%d/%m/%Y" ->
              [day, month, year] = String.split(value, "/") |> Enum.map(&String.to_integer/1)
              Date.new!(year, month, day)

            "%m/%d/%Y" ->
              [month, day, year] = String.split(value, "/") |> Enum.map(&String.to_integer/1)
              Date.new!(year, month, day)
          end
        end
      end
    end

    test "it should pass the context to the set function" do
      changeset =
        %User{}
        |> SetContextBirthdayForm.new(%{date_format: "%d/%m/%Y"})
        |> SetContextBirthdayForm.validate(%{"birthday" => "23/12/2010"})
        |> SetContextBirthdayForm.changeset()

      assert changeset.changes.birthday == ~D[2010-12-23]

      changeset =
        %User{}
        |> SetContextBirthdayForm.new(%{date_format: "%m/%d/%Y"})
        |> SetContextBirthdayForm.validate(%{"birthday" => "12/23/2010"})
        |> SetContextBirthdayForm.changeset()

      assert changeset.changes.birthday == ~D[2010-12-23]
    end
  end

  describe "set with multiple parameters" do
    defmodule SetPriceWithCurrencyForm do
      use SmartForm

      smart_form do
        field :price, :string, set: :parse_price
      end

      def parse_price(:price, value, context) do
        if value do
          cents = String.to_float(value) * 100
          %{price_cents: cents, price_currency: context.currency}
        end
      end
    end

    test "should set both price_cents and price_currency" do
      changeset =
        %Book{}
        |> SetPriceWithCurrencyForm.new(%{currency: "USD"})
        |> SetPriceWithCurrencyForm.validate(%{"price" => "10.00"})
        |> SetPriceWithCurrencyForm.changeset()

      assert changeset.changes.price_cents == 1000
      assert changeset.changes.price_currency == "USD"
    end
  end
end
