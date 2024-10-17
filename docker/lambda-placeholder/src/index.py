import json
import pandas as pd


def handler(event, context):
    # Extract Video URL
    df = pd.DataFrame(event.values())
    output = df.sum()
    return json.dumps({"output": int(output.iloc[0])})
