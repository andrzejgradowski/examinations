class DatatablesController < ApplicationController

PL =  {
        "sProcessing":   "<span class='fa fa-circle-notch fa-spin fa-3x' style='color:lightgrey;'></span>",
        "sLengthMenu":   "<span class='fa fa-arrows-alt-v'></span> _MENU_",
        "sZeroRecords":  "Nie znaleziono pasujących pozycji",
        "sEmptyTable":   "Brak danych",
        "sInfo":         "Pozycje od _START_ ... _END_ z _TOTAL_ łącznie",
        "sInfoEmpty":    "Pozycji 0 z 0 dostępnych",
        "sInfoFiltered": "(filtrowanie spośród _MAX_ dostępnych pozycji)",
        "sInfoPostFix":  "",
        "sInfoThousands":  " ",
        "sLoadingRecords": "Wczytywanie...",
        "sSearch":       "<span class='fa fa-search'></span>",
        "oPaginate": {
          "sFirst":     "<<",
          "sPrevious":  "<",
          "sNext":      ">",
          "sLast":      ">>"
        },
        "oAria": {
          "sSortAscending":  ": aktywuj, by posortować kolumnę rosnąco",
          "sSortDescending": ": aktywuj, by posortować kolumnę malejąco"
        }
      }      

EN =  {
        "sProcessing":     "<span class='fa fa-circle-notch fa-spin fa-3x' style='color:lightgrey;'></span>",
        "sLengthMenu":     "<span class='fa fa-arrows-alt-v'></span> _MENU_",
        "sZeroRecords":    "No matching records found",
        "sEmptyTable":     "No data available in table",
        "sInfo":           "Showing _START_ ... _END_ of _TOTAL_ entries",
        "sInfoEmpty":      "Showing 0 to 0 of 0 entries",
        "sInfoFiltered":   "(filtered from _MAX_ total entries)",
        "sInfoPostFix":    "",
        "sInfoThousands":  ",",
        "sLoadingRecords": "Loading...",
        "sSearch":         "<span class='fa fa-search'></span>",
        "oPaginate": {
          "sFirst":     "<<",
          "sPrevious":  "<",
          "sNext":      ">",
          "sLast":      ">>"
        },
        "oAria": {
          "sSortAscending":  ": activate to sort column ascending",
          "sSortDescending": ": activate to sort column descending"
        }
      }



  def lang
    respond_to do |format|

      #format.json { render template: "datatables/langue", formats: :json }

      format.json { render json: langue(params[:locale]) }
    end
  end

  private
    def langue (loc)
      case loc
      when "pl"
        PL
      when "en"
        EN
      end
    end

end
