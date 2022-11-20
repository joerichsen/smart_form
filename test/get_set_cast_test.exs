defmodule GetSetCastTest do
  use SmartForm.DataCase
  doctest SmartForm

  alias SmartForm.User

  describe "get" do
    defmodule GetForm do
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
      form = GetForm.new(user)
      assert form.data.birthday == "23/12/2010"
    end
  end
end
