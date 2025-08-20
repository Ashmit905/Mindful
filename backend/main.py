from flask import Flask, request, jsonify
from flask_cors import CORS
from ai import getQuote, get_insights

app = Flask(__name__)

# Enable CORS for all origins
CORS(app)

@app.route('/api/quote', methods=['POST'])
def get_quote():
    message = getQuote()
    return jsonify({"message": message})

@app.route('/api/insights', methods=['POST'])
def generate_insights():
    user_data = request.get_json()
    try:
        analysis = get_insights(user_data)
        return jsonify(analysis)
    except Exception as e:
        print(f"Endpoint Error: {e}")
        return jsonify({
            "success": False,
            "message": "Service unavailable",
            "insights": [],
            "suggestions": []
        })

if __name__ == '__main__':
    app.run(debug=True)